import simd
import Foundation

func main() throws {
    let input: [String] = try readInput(fromTestFile: true, separator: "\n\n")
    let scanners: [[simd_float3]] = input.map({
        let lineSplit = $0.split(separator: "\n")
        return lineSplit[1..<lineSplit.count].map({ coordLine in
            let coordSplit = coordLine.split(separator: ",")
            return simd_float3(x: Float(coordSplit[0])!, y: Float(coordSplit[1])!, z: 1)
        })
    })

    var allPairs: [(simd_float3, simd_float3)] = []

    for a in scanners[1] {
        for b in scanners[0] {
            allPairs.append((a, b))
        }
    }

    for p in allPairs {
        print(p)
        let translation = makeTranslationMatrix(tx: p.1.x - p.0.x, ty: p.1.y - p.0.y)
        // Translate each coord in the non-zero set
        var matches = 0
        for coord in scanners[1] {
            // Translate the coord
            let translated = translation * coord
            print(coord, translated)
            if scanners[0].contains(translated) {
                matches += 1
            }
        }
        print(matches)
    }
    assert(false)


















//    let originalCoordList = scanners[0]
//    let toCheckCoordList = scanners[1]
//
//    for rotationMatrix in rotationMatrices {
////        print("\n")
////        print(rotationMatrix)
////        originalCoordList.forEach({ print($0 * rotationMatrix) })
//
//        let originalRotatedCoords = originalCoordList.map({ $0 * rotationMatrix })
//        let toCheckRotatedCoords = toCheckCoordList.map({ $0 * rotationMatrix })
//
//        for aCoord in toCheckRotatedCoords {
//            for bCoord in originalRotatedCoords {
//                let translationMatrix = makeTranslationMatrix(tx: bCoord.x - aCoord.x, ty: bCoord.y - aCoord.y, tz: bCoord.z - aCoord.z)
//                // Translate all the toCheck coords by the matrix, check if it's in original rotated
//                var matched = 0
//                for coord in toCheckRotatedCoords {
//                    // translate it
//                    let translated = coord * translationMatrix
//                    if originalRotatedCoords.contains(translated) {
//                        matched += 1
//                    }
//                }
//
//                if matched >= 12 {
//                    print("Done with rotation: \(rotationMatrix) \(aCoord) \(bCoord)")
//                    assert(false)
//                }
//
//            }
//        }
//    }
}

private func makeTranslationMatrix(tx: Float, ty: Float) -> simd_float3x3 {
    var matrix = matrix_identity_float3x3

    matrix[2, 0] = tx
    matrix[2, 1] = ty

    return matrix
}

private func makeTranslationMatrix(tx: Float, ty: Float, tz: Float) -> simd_float3x3 {
    var matrix = matrix_identity_float3x3

    matrix[2, 0] = tx
    matrix[2, 1] = ty
    matrix[2, 2] = tz

    return matrix
}

private func scannersOverlap(originalCoordSet: Set<simd_float3>, translatableCoordSet: Set<simd_float3>, rotation: float3x3, threshold: Int) -> [simd_float3]? {
    let rotatedOriginalCoords = originalCoordSet.map({ $0 * rotation })
    let rotatedTranslatableCoords = translatableCoordSet.map({ $0 * rotation })

    for aCoord in rotatedTranslatableCoords {
        for bCoord in rotatedOriginalCoords {
            let translationMatrix = makeTranslationMatrix(tx: bCoord.x - aCoord.x, ty: bCoord.y - aCoord.y, tz: bCoord.z - aCoord.z)
            var matched: [simd_float3] = []
            for coordToTranslate in rotatedTranslatableCoords {
                let translatedVector = translationMatrix * coordToTranslate
                if rotatedOriginalCoords.contains(translatedVector) {
//                    print("match")
                    matched.append(translatedVector)
                }
            }
//            print
            print(matched.count)
            if matched.count >= threshold {
                return matched
            }
        }
    }

    return nil
}

try main()

let rotationMatrices: [float3x3] = [
    float3x3(rows:[simd_float3(1,    0,    0),
    simd_float3(0,    1,    0),
    simd_float3(0,    0,    1)]),

    float3x3(rows:[simd_float3(1,    0,    0),
    simd_float3(0,    0,    -1),
    simd_float3(0,    1,    0)]),

    float3x3(rows:[simd_float3(1,    0,    0),
    simd_float3(0,    -1,    0),
    simd_float3(0,    0,    -1)]),

    float3x3(rows:[simd_float3(1,    0,    0),
    simd_float3(0,    0,    1),
    simd_float3(0,    -1,    0)]),

    float3x3(rows:[simd_float3(0,    -1,    0),
    simd_float3(1,    0,    0),
    simd_float3(0,    0,    1)]),

    float3x3(rows:[simd_float3(0,    0,    1),
    simd_float3(1,    0,    0),
    simd_float3(0,    1,    0)]),

    float3x3(rows:[simd_float3(0,    1,    0),
    simd_float3(1,    0,    0),
    simd_float3(0,    0,    -1)]),

    float3x3(rows:[simd_float3(0,    0,    -1),
    simd_float3(1,    0,    0),
    simd_float3(0,    -1,    0)]),

    float3x3(rows:[simd_float3(-1,    0,    0),
    simd_float3(0,    -1,    0),
    simd_float3(0,    0,    1)]),

    float3x3(rows:[simd_float3(-1,    0,    0),
    simd_float3(0,    0,    -1),
    simd_float3(0,    -1,    0)]),

    float3x3(rows:[simd_float3(-1,    0,    0),
    simd_float3(0,    1,    0),
    simd_float3(0,    0,    -1)]),

    float3x3(rows:[simd_float3(-1,    0,    0),
    simd_float3(0,    0,    1),
    simd_float3(0,    1,    0)]),

    float3x3(rows:[simd_float3(0,    1,    0),
    simd_float3(-1,    0,    0),
    simd_float3(0,    0,    1)]),

    float3x3(rows:[simd_float3(0,    0,    1),
    simd_float3(-1,    0,    0),
    simd_float3(0,    -1,    0)]),

    float3x3(rows:[simd_float3(0,    -1,    0),
    simd_float3(-1,    0,    0),
    simd_float3(0,    0,    -1)]),

    float3x3(rows:[simd_float3(0,    0,    -1),
    simd_float3(-1,    0,    0),
    simd_float3(0,    1,    0)]),

    float3x3(rows:[simd_float3(0,    0,    -1),
    simd_float3(0,    1,    0),
    simd_float3(1,    0,    0)]),

    float3x3(rows:[simd_float3(0,    1,    0),
    simd_float3(0,    0,    1),
    simd_float3(1,    0,    0)]),

    float3x3(rows:[simd_float3(0,    0,    1),
    simd_float3(0,    -1,    0),
    simd_float3(1,    0,    0)]),

    float3x3(rows:[simd_float3(0,    -1,    0),
    simd_float3(0,    0,    -1),
    simd_float3(1,    0,    0)]),

    float3x3(rows:[simd_float3(0,    0,    -1),
    simd_float3(0,    -1,    0),
    simd_float3(-1,    0,    0)]),

    float3x3(rows:[simd_float3(0,    -1,    0),
    simd_float3(0,    0,    1),
    simd_float3(-1,    0,    0)]),

    float3x3(rows:[simd_float3(0,    0,    1),
    simd_float3(0,    1,    0),
    simd_float3(-1,    0,    0)]),

    float3x3(rows:[simd_float3(0,    1,    0),
    simd_float3(0,    0,    -1),
    simd_float3(-1,    0,    0)]),
    ]
