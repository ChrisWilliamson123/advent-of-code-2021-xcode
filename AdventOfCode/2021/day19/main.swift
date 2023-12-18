import simd

func main() throws {
    let input: [String] = try readInput(fromTestFile: false, separator: "\n\n")
    let scanners = buildInitialScanners(from: input)

    /// Stores the beacons for each scanner (translated into beacon 0's coordinate space)
    var scannerToBeaconsMap: [Int: Set<simd_float4>] = [0: scanners[0]]

    var scannersCheckedForOverlaps: Set<Int> = []
    var scannerPositions: Set<simd_float4> = []

    let allScannersChecked = { scannerToBeaconsMap.count == scanners.count }

    while !allScannersChecked() {
        /// Will get a random scanner that hasn't been checked yet
        let nextScannerToCheck = scannerToBeaconsMap.first(where: { !scannersCheckedForOverlaps.contains($0.key) })!

        /// Loop through scanners that are not the scanner being checked and that aren't scanners that have already been resolved
        for otherScanner in 0..<scanners.count where otherScanner != nextScannerToCheck.key && !scannerToBeaconsMap.keys.contains(otherScanner) {
            defer { scannersCheckedForOverlaps.insert(nextScannerToCheck.key) }

            guard let matching = getMatchingBeaconsBetween(baseScanner: nextScannerToCheck.value,
                                                           nonBaseScanner: Set(scanners[otherScanner])) else { continue }

            scannerToBeaconsMap[otherScanner] = matching.allTransformedNonBaseCoordsIntoBaseSpace
            scannerPositions.insert(matching.scannerPosition)

            print("Scanner \(otherScanner) is at \(matching.scannerPosition)")
        }
    }

    let allBeacons = Set(scannerToBeaconsMap.values.flatMap({ $0 }))
    print("Part 1:", allBeacons.count)

    let scannerPairs = Array(scannerPositions).combinations(count: 2)
    let maxDistanceBetweenScanners: Float = scannerPairs
        .reduce(0, { max($0, abs($1[0].x - $1[1].x) + abs($1[0].y - $1[1].y) + abs($1[0].z - $1[1].z)) })
    print("Part 2:", Int(maxDistanceBetweenScanners))
}

/*
 Will optionally return a tuple where:
    item 0 is the relative scanners position from the base
    item 1 is a set containing all of the relative scanner's beacons translated to the base scanner's coordinate space
 */
// swiftlint:disable:next line_length
private func getMatchingBeaconsBetween(baseScanner: Set<simd_float4>, nonBaseScanner: Set<simd_float4>) -> (scannerPosition: simd_float4, allTransformedNonBaseCoordsIntoBaseSpace: Set<simd_float4>)? {
    // Loop through all possible orientations that a scanner can have
    for rotationMatrix in RotationMatrixStore.allRotationMatrices {
        let rotatedBeacons: Set<simd_float4> = nonBaseScanner.reduce(into: [], { $0.insert(rotationMatrix * $1) })

        var pairs: [(simd_float4, simd_float4)] = []
        for a in rotatedBeacons {
            for b in baseScanner {
                pairs.append((a, b))
            }
        }

        for p in pairs {
            var translationMatrix = matrix_identity_float4x4
            let translationColumn = simd_float4(arrayLiteral: p.1.x - p.0.x, p.1.y - p.0.y, p.1.z - p.0.z, 1)
            translationMatrix[3] = translationColumn

            let matchingCoordCount = rotatedBeacons.reduce(0, { baseScanner.contains(translationMatrix * $1) ? $0 + 1 : $0 })

            if matchingCoordCount >= 12 {
                var matrix = rotationMatrix
                matrix[3] = translationColumn
                let allNonBaseTransformed: Set<simd_float4> = nonBaseScanner.reduce(into: [], { $0.insert(matrix * $1) })
                return (simd_float4(x: -translationColumn.x, y: -translationColumn.y, z: -translationColumn.z, w: 1), allNonBaseTransformed)
            }
        }
    }

    return nil
}

private func buildInitialScanners(from input: [String]) -> [Set<simd_float4>] {
    var scanners: [Set<simd_float4>] = []

    for text in input {
        let coordsAsStrings = text.split(separator: "\n").suffix(from: 1)
        scanners.append(Set(coordsAsStrings.map({ coord in
            let coordSplit = coord.split(separator: ",")
            return simd_float4(x: Float(coordSplit[0])!, y: Float(coordSplit[1])!, z: Float(coordSplit[2])!, w: 1)
        })))
    }

    return scanners
}

Timer.time(main)
