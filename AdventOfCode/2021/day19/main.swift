import simd

func main() throws {
    let input: [String] = try readInput(fromTestFile: false, separator: "\n\n")
    test3DMatchingScanners(input: input)
}

private func getAllRotatedCoords(using rotation: float4x4, on coords: Set<simd_float4>) -> Set<simd_float4> {
    coords.reduce(into: [], { $0.insert(rotation * $1) })
}

private func perform3DTranslation(origin: simd_float4, tx: Float, ty: Float, tz: Float) -> simd_float4 {
    var transformationMatrix = matrix_identity_float4x4
    transformationMatrix[3] = [tx, ty, tz, 1]
    return transformationMatrix * origin
}

private func test3DMatchingScanners(input: [String]) {
    let scannersText = input

    var scanners: [[simd_float4]] = []

    for text in scannersText {
        let coordsAsStrings = text.split(separator: "\n").suffix(from: 1)
        scanners.append(coordsAsStrings.map({ coord in
            let coordSplit = coord.split(separator: ",")
            return simd_float4(x: Float(coordSplit[0])!, y: Float(coordSplit[1])!, z: Float(coordSplit[2])!, w: 1)
        }))
    }

    var allBeacons: Set<simd_float4> = Set(scanners[0])
    var scannerCoordsInZeroSpace: [Int: Set<simd_float4>] = [0: allBeacons]
    var done: Set<Int> = []
    var scannerPositions: Set<simd_float4> = []

    while scannerCoordsInZeroSpace.count != scanners.count {
        let next = scannerCoordsInZeroSpace.first(where: { !done.contains($0.key) })!
        print("Attempting to get overlapping scanner for base scanner \(next.key)")
        for nbIndex in 0..<scanners.count where nbIndex != next.key && !scannerCoordsInZeroSpace.keys.contains(nbIndex) {
            if let matching = getMatchingBeaconsBetween(baseScanner: next.value, nonBaseScanner: Set(scanners[nbIndex])) {
                scannerCoordsInZeroSpace[nbIndex] = matching.allTransformedNonBaseCoordsIntoBaseSpace
                for c in matching.allTransformedNonBaseCoordsIntoBaseSpace {
                    allBeacons.insert(c)
                }

                print("Scanner \(nbIndex) is at \(matching.scannerPosition) to 0")
                scannerPositions.insert(matching.scannerPosition)
            } else {
                print("Scanner \(nbIndex) does not overlap with scanner \(next.key)")
            }
            done.insert(next.key)
        }
    }

    print("Part 1:", allBeacons.count)

    let scannerPairs = Array(scannerPositions).combinations(count: 2)
    let maxDistance: Float = scannerPairs.reduce(0, { max($0, abs($1[0].x - $1[1].x) + abs($1[0].y - $1[1].y) + abs($1[0].z - $1[1].z)) })
    print("Part 2:", Int(maxDistance))
}

/// Will optionally return a translation that describes how to get the nonBaseScanner to the base
private func getMatchingBeaconsBetween(baseScanner: Set<simd_float4>, nonBaseScanner: Set<simd_float4>) -> (scannerPosition: simd_float4,
                                                                                                            allTransformedNonBaseCoordsIntoBaseSpace: Set<simd_float4>)? {
    // We need to go through all rotations and check whether the rotation ends up matching the coords
    for rotationMatrix in RotationMatrixStore.allRotationMatrices {
        let scannerToCheckWithRotatedCoords = getAllRotatedCoords(using: rotationMatrix, on: nonBaseScanner)

        // Want to know if scanner 1 with it's rotation overlaps scanner 0
        // Need to get all pairs of coordinates [(a, b)] where a is scanner 1 coord and b is scanner 0 coord
        var pairs: [(simd_float4, simd_float4)] = []
        for a in scannerToCheckWithRotatedCoords {
            for b in baseScanner {
                pairs.append((a, b))
            }
        }

        for p in pairs {
            let xDiff = p.1.x - p.0.x
            let yDiff = p.1.y - p.0.y
            let zDiff = p.1.z - p.0.z

            var matchingCoordCount = 0

            // For each coordinate in the non-base scanner, translate it by the difference.
            // If the translated coord is in the base scanner's coord set, increase the count
            for nonBaseCoord in scannerToCheckWithRotatedCoords {
                let translated = perform3DTranslation(origin: nonBaseCoord, tx: xDiff, ty: yDiff, tz: zDiff)
                if baseScanner.contains(translated) { matchingCoordCount += 1 }
            }

            if matchingCoordCount >= 12 {
                var matrix = rotationMatrix
                matrix[3] = [xDiff, yDiff, zDiff, 1]
                let allNonBaseTransformed: Set<simd_float4> = nonBaseScanner.reduce(into: [], { $0.insert(matrix * $1) })
                return (simd_float4(x: -xDiff, y: -yDiff, z: -zDiff, w: 1), allNonBaseTransformed)
            }
        }
    }
    return nil
}

try main()
