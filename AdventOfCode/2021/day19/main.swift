import simd

func main() throws {
    let input: [String] = try readInput(fromTestFile: false, separator: "\n\n")
    test3DMatchingScanners(input: input)
}

private func getAllRotatedCoords(using rotation: float4x4, on coords: [simd_float4]) -> [simd_float4] {
    coords.map({ rotation * $0 })
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
    var scannerCoordsInZeroSpace: [Int: [simd_float4]] = [0:scanners[0]]
    var done: Set<Int> = []

    while scannerCoordsInZeroSpace.count != scanners.count {
        let next = scannerCoordsInZeroSpace.first(where: { !done.contains($0.key) })!
        print("Attempting to get overlapping scanner for base scanner \(next.key)")
        for nbIndex in 0..<scanners.count where nbIndex != next.key && !scannerCoordsInZeroSpace.keys.contains(nbIndex) {
            if let matching = getMatchingBeaconsBetween(baseScanner: next.value, nonBaseScanner: scanners[nbIndex]) {
                scannerCoordsInZeroSpace[nbIndex] = matching.allTransformedNonBaseCoordsIntoBaseSpace
                for c in matching.allTransformedNonBaseCoordsIntoBaseSpace {
                    allBeacons.insert(c)
                }
                print("Scanner \(nbIndex) is at inverse \(matching.baseScannerPositionRelativeToNonBase) to 0")
            } else {
                print("Scanner \(nbIndex) does not overlap with scanner \(next.key)")
            }
            done.insert(next.key)
        }
    }

    print(allBeacons.count)
}

/// Will optionally return a translation that describes how to get the nonBaseScanner to the base
private func getMatchingBeaconsBetween(baseScanner: [simd_float4], nonBaseScanner: [simd_float4]) -> (baseScannerPositionRelativeToNonBase: simd_float4,
                                                                                                      allTransformedNonBaseCoordsIntoBaseSpace: [simd_float4])? {
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
            var matchingCoordsRelativeToNonBase: [simd_float4] = []
            var matchingCoordsRelativeToBase: [simd_float4] = []

            // For each coordinate in the non-base scanner, translate it by the difference.
            // If the translated coord is in the base scanner's coord set, increase the count
            for nonBaseCoord in scannerToCheckWithRotatedCoords {
                let translated = perform3DTranslation(origin: nonBaseCoord, tx: xDiff, ty: yDiff, tz: zDiff)

                if baseScanner.contains(translated) {
                    matchingCoordCount += 1
                    matchingCoordsRelativeToNonBase.append(nonBaseScanner[scannerToCheckWithRotatedCoords.firstIndex(of: nonBaseCoord)!])
                    matchingCoordsRelativeToBase.append(translated)
                }
            }

            if matchingCoordCount >= 12 {
                var matrix = rotationMatrix
                matrix[3] = [xDiff, yDiff, zDiff, 1]
                let allNonBaseTransformed: [simd_float4] = nonBaseScanner.map({ matrix * $0 })
                return (simd_float4(x: xDiff, y: yDiff, z: zDiff, w: 1), allNonBaseTransformed)
            }
        }
    }
    return nil
}

try main()
