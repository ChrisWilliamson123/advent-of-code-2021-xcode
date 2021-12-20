import simd

func main() throws {
//    testTranslationsAndRotations()
//    test2DMatchingScanners()
    test3DMatchingScanners()
    
}

private func getAllRotatedCoords(using rotation: float4x4, on coords: [simd_float4]) -> [simd_float4] {
    coords.map({ rotation * $0 })
}

private func perform2DTranslation(origin: simd_float3, tx: Float, ty: Float) -> simd_float3 {
    var transformationMatrix = matrix_identity_float3x3
    transformationMatrix[2][0] = tx
    transformationMatrix[2][1] = ty
    return transformationMatrix * origin
}

private func perform3DTranslation(origin: simd_float4, tx: Float, ty: Float, tz: Float) -> simd_float4 {
    var transformationMatrix = matrix_identity_float4x4
    transformationMatrix[3] = [tx, ty, tz, 1]
    return transformationMatrix * origin
}

private func test3DMatchingScanners() {
    let input = """
    --- scanner 0 ---
    404,-588,-901
    528,-643,409
    -838,591,734
    390,-675,-793
    -537,-823,-458
    -485,-357,347
    -345,-311,381
    -661,-816,-575
    -876,649,763
    -618,-824,-621
    553,345,-567
    474,580,667
    -447,-329,318
    -584,868,-557
    544,-627,-890
    564,392,-477
    455,729,728
    -892,524,684
    -689,845,-530
    423,-701,434
    7,-33,-71
    630,319,-379
    443,580,662
    -789,900,-551
    459,-707,401

    --- scanner 1 ---
    686,422,578
    605,423,415
    515,917,-361
    -336,658,858
    95,138,22
    -476,619,847
    -340,-569,-846
    567,-361,727
    -460,603,-452
    669,-402,600
    729,430,532
    -500,-761,534
    -322,571,750
    -466,-666,-811
    -429,-592,574
    -355,545,-477
    703,-491,-529
    -328,-685,520
    413,935,-424
    -391,539,-444
    586,-435,557
    -364,-763,-893
    807,-499,-711
    755,-354,-619
    553,889,-390

    --- scanner 2 ---
    649,640,665
    682,-795,504
    -784,533,-524
    -644,584,-595
    -588,-843,648
    -30,6,44
    -674,560,763
    500,723,-460
    609,671,-379
    -555,-800,653
    -675,-892,-343
    697,-426,-610
    578,704,681
    493,664,-388
    -671,-858,530
    -667,343,800
    571,-461,-707
    -138,-166,112
    -889,563,-600
    646,-828,498
    640,759,510
    -630,509,768
    -681,-892,-333
    673,-379,-804
    -742,-814,-386
    577,-820,562

    --- scanner 3 ---
    -589,542,597
    605,-692,669
    -500,565,-823
    -660,373,557
    -458,-679,-417
    -488,449,543
    -626,468,-788
    338,-750,-386
    528,-832,-391
    562,-778,733
    -938,-730,414
    543,643,-506
    -524,371,-870
    407,773,750
    -104,29,83
    378,-903,-323
    -778,-728,485
    426,699,580
    -438,-605,-362
    -469,-447,-387
    509,732,623
    647,635,-688
    -868,-804,481
    614,-800,639
    595,780,-596

    --- scanner 4 ---
    727,592,562
    -293,-554,779
    441,611,-461
    -714,465,-776
    -743,427,-804
    -660,-479,-426
    832,-632,460
    927,-485,-438
    408,393,-506
    466,436,-512
    110,16,151
    -258,-428,682
    -393,719,612
    -211,-452,876
    808,-476,-593
    -575,615,604
    -485,667,467
    -680,325,-822
    -627,-443,-432
    872,-547,-609
    833,512,582
    807,604,487
    839,-516,451
    891,-625,532
    -652,-548,-490
    30,-46,-14
    """
    let scannersText = input.components(separatedBy: "\n\n")

    var scanners: [[simd_float4]] = []

    for text in scannersText {
        let coordsAsStrings = text.split(separator: "\n").suffix(from: 1)
        scanners.append(coordsAsStrings.map({ coord in
            let coordSplit = coord.split(separator: ",")
            return simd_float4(x: Float(coordSplit[0])!, y: Float(coordSplit[1])!, z: Float(coordSplit[2])!, w: 1)
        }))
    }

//    print(scanners)

    let baseScanner = scanners[0]
    let scannerToCheck = scanners[1]

    // We need to go through all rotations and check whether the rotation ends up matching the coords
    for (rotationIndex, rotationMatrix) in RotationMatrixStore.allRotationMatrices.enumerated() {
        let scannerToCheckWithRotatedCoords = getAllRotatedCoords(using: rotationMatrix, on: scannerToCheck)

        // Want to know if scanner 1 with it's rotation overlaps scanner 0
        // Need to get all pairs of coordinates [(a, b)] where a is scanner 1 coord and b is scanner 0 coord

        var pairs: [(simd_float4, simd_float4)] = []
        for a in scannerToCheckWithRotatedCoords {
            for b in baseScanner {
                pairs.append((a, b))
            }
        }

        for p in pairs {
//            print("Pair: \(p)")
            let xDiff = p.1.x - p.0.x
            let yDiff = p.1.y - p.0.y
            let zDiff = p.1.z - p.0.z
//            print("\tDifference: \(xDiff) \(yDiff) \(zDiff)")

            var matchingCoordCount = 0
            var matchingCoords: [simd_float4] = []
            // For each coordinate in the non-base scanner, translate it by the difference.
            // If the translated coord is in the base scanner's coord set, increase the count
            for nonBaseCoord in scannerToCheckWithRotatedCoords {
                let translated = perform3DTranslation(origin: nonBaseCoord, tx: xDiff, ty: yDiff, tz: zDiff)
//                print("\t\tTranslated: \(nonBaseCoord) -> \(translated)")
                if baseScanner.contains(translated) {
                    matchingCoordCount += 1
                    matchingCoords.append(scannerToCheck[scannerToCheckWithRotatedCoords.firstIndex(of: nonBaseCoord)!])
                }
            }

            //        print("\tOverlapping coord count: \(matchingCoordCount)")
            if matchingCoordCount >= 12 {
                print("Match found with rotation index", rotationIndex)
                print("Matching coords relative to base:")
                for m in matchingCoords { print("\t", m) }
                let nonBaseScannerPosition = simd_float4(x: xDiff, y: yDiff, z: zDiff, w: 1)
                print("Non-base scanner pos relative to base scanner: ", nonBaseScannerPosition)
                assert(false)
            }
        }
    }
}

private func test2DMatchingScanners() {
    let input = """
    --- scanner 0 ---
    0,2
    4,1
    3,3

    --- scanner 1 ---
    -1,-1
    -5,0
    -2,1
    """
    let scannersText = input.components(separatedBy: "\n\n")

    var scanners: [[simd_float3]] = []

    for text in scannersText {
        let coordsAsStrings = text.split(separator: "\n").suffix(from: 1)
        scanners.append(coordsAsStrings.map({ coord in
            let coordSplit = coord.split(separator: ",")
            return simd_float3(x: Float(coordSplit[0])!, y: Float(coordSplit[1])!, z: 1)
        }))
    }

    print(scanners)

    let baseScanner = scanners[0]
    let scannerToCheck = scanners[1]

    // Want to know if scanner 1 overlaps scanner 0
    // Need to get all pairs of coordinates [(a, b)] where a is scanner 1 coord and b is scanner 0 coord

    var pairs: [(simd_float3, simd_float3)] = []
    for a in scannerToCheck {
        for b in baseScanner {
            pairs.append((a, b))
        }
    }

    for p in pairs {
        print("Pair: \(p)")
        let xDiff = p.1.x - p.0.x
        let yDiff = p.1.y - p.0.y
        print("\tDifference: \(xDiff) \(yDiff)")

        var matchingCoordCount = 0
        // For each coordinate in the non-base scanner, translate it by the difference.
        // If the translated coord is in the base scanner's coord set, increase the count
        for nonBaseCoord in scannerToCheck {
            let translated = perform2DTranslation(origin: nonBaseCoord, tx: xDiff, ty: yDiff)
            print("\t\tTranslated: \(nonBaseCoord) -> \(translated)")
            if baseScanner.contains(translated) {
                matchingCoordCount += 1
            }
        }

        print("\tOverlapping coord count: \(matchingCoordCount)")
    }
}

private func testTranslationsAndRotations() {
    let example2D = simd_float3(x: 2, y: 3, z: 1)
    print(perform2DTranslation(origin: example2D, tx: 3, ty: -5))

    let example3D = simd_float4(x: 3, y: 5, z: 7, w: 1)
    print(perform3DTranslation(origin: example3D, tx: 1, ty: 2, tz: 3))

    let coordsToRotate: [simd_float4] = [
        simd_float4(x: -1, y: -1, z: 1, w:1),
        simd_float4(x: 5, y: 6, z: -4, w:1),
        simd_float4(x: 8, y: 0, z: 7, w:1)
    ]
    for rotation in RotationMatrixStore.allRotationMatrices {
        print("\n")
        for c in getAllRotatedCoords(using: rotation, on: coordsToRotate) {
            print(c)
        }
    }
}

try main()
