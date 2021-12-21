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
    -377,550,716
    405,-463,594
    -612,-603,479
    -673,637,-463
    536,-465,715
    821,322,-697
    -676,-693,500
    643,432,654
    366,-500,-472
    708,409,-755
    469,-498,555
    738,371,759
    600,282,729
    362,-630,-324
    -446,-778,-395
    -679,-672,612
    -450,654,697
    353,-429,-389
    -661,719,-393
    118,-178,-1
    702,313,-718
    -540,-676,-341
    -716,754,-469
    -313,635,722
    -546,-749,-540
    -46,-64,45

    --- scanner 1 ---
    -393,569,-783
    823,673,744
    492,605,-667
    568,-702,420
    498,-690,338
    -442,536,-928
    -458,-493,-747
    -617,-342,422
    -654,709,686
    539,-496,-476
    540,570,-668
    -416,521,-829
    756,-480,-461
    -387,-515,-848
    -549,614,625
    -611,-406,507
    666,628,-671
    -592,-479,403
    632,-478,-385
    802,792,735
    860,679,648
    27,17,-91
    -624,571,775
    -535,-422,-848
    574,-745,303

    --- scanner 2 ---
    558,-741,-564
    646,-807,485
    464,437,812
    -898,-528,468
    616,-770,-508
    -127,-22,17
    351,393,-850
    532,-629,-522
    -680,-690,-789
    600,353,768
    -655,-827,-770
    593,-678,448
    675,-648,590
    -808,525,-539
    -765,-461,537
    335,474,-887
    -777,396,-580
    241,407,-941
    -787,793,667
    -973,848,720
    -661,-763,-685
    -789,519,-676
    449,424,815
    -815,754,730
    -42,81,-107
    -877,-464,558

    --- scanner 3 ---
    -436,572,-578
    746,-456,727
    -475,513,-649
    -451,-549,481
    -562,-572,-515
    774,-516,696
    -704,791,507
    768,-722,-551
    812,-661,-568
    -613,684,551
    700,767,716
    -303,592,-650
    116,21,-89
    -408,-507,547
    753,-717,750
    609,753,-601
    -62,-9,37
    553,672,-596
    836,-673,-599
    -467,-404,-483
    -660,817,634
    -609,-356,-546
    602,796,-590
    692,646,766
    -565,-477,532
    702,620,743

    --- scanner 4 ---
    538,-453,-833
    -126,24,29
    -352,-473,-587
    -444,-449,-740
    691,-464,520
    626,828,344
    -565,-317,406
    775,942,-788
    -369,-409,417
    -708,823,-645
    727,935,-697
    -746,539,507
    -806,434,481
    -789,742,-763
    -556,-362,404
    -690,470,523
    593,877,489
    405,-436,-796
    317,-447,-785
    -404,-427,-788
    -13,189,-5
    -698,727,-823
    600,898,-737
    561,-551,518
    641,854,443
    733,-626,469

    --- scanner 5 ---
    46,10,147
    758,-651,532
    -527,-618,452
    -823,464,-569
    690,764,759
    -564,-447,-551
    764,-302,-267
    684,881,802
    456,449,-735
    435,440,-616
    107,94,-30
    760,846,747
    -677,-709,468
    -647,455,-499
    -408,-549,-539
    398,536,-622
    -293,614,774
    829,-503,-276
    -385,-416,-489
    -272,801,808
    -563,-622,372
    -612,469,-575
    613,-622,632
    -278,753,780
    681,-373,-280
    812,-549,626

    --- scanner 6 ---
    579,574,-541
    -505,493,-632
    618,658,359
    -341,743,774
    -322,-636,574
    716,580,-522
    366,-369,516
    -654,544,-722
    401,-424,440
    -413,-618,481
    -785,-692,-593
    -785,-599,-445
    466,-635,-650
    675,451,-553
    89,132,-70
    -427,825,855
    -398,-634,698
    570,-708,-669
    -60,27,13
    522,657,457
    -376,606,841
    -684,-621,-516
    485,-772,-675
    475,716,376
    -647,496,-573
    483,-412,510

    --- scanner 7 ---
    512,585,-747
    807,772,880
    733,795,840
    -767,-876,-603
    -719,662,750
    -612,458,-552
    570,-882,858
    -589,-932,-661
    623,-601,-378
    -343,-464,739
    -589,632,-556
    746,-608,-532
    494,492,-838
    -652,610,660
    -554,584,-555
    111,-115,-49
    589,-757,885
    -618,631,899
    496,368,-762
    618,-644,-539
    696,-814,921
    -640,-913,-544
    737,746,813
    -310,-533,587
    -23,-193,76
    -85,0,-51
    -447,-527,622

    --- scanner 8 ---
    -419,640,-664
    -722,-533,531
    705,861,595
    577,-689,716
    -842,-385,512
    632,-792,-344
    815,768,660
    490,-691,586
    -502,623,-798
    -554,-811,-585
    676,809,607
    560,496,-785
    -943,400,567
    415,-740,758
    679,-805,-531
    732,438,-813
    -792,347,621
    724,-803,-540
    -489,-738,-726
    -746,-370,499
    -2,59,-33
    558,494,-753
    -515,574,-768
    -486,-634,-564
    -122,-93,-71
    -872,325,554

    --- scanner 9 ---
    506,-688,-561
    571,721,622
    503,-562,-503
    -709,-714,-463
    -835,437,457
    -948,-735,-497
    314,-589,962
    495,809,-475
    -788,360,-772
    -612,-499,488
    291,-602,907
    -580,-584,424
    -119,8,40
    -636,429,-805
    408,627,663
    555,634,776
    301,-483,836
    -799,-766,-396
    -671,423,-668
    -725,535,411
    10,-85,163
    554,772,-348
    -726,558,457
    507,-736,-526
    612,828,-526
    -444,-607,500

    --- scanner 10 ---
    -643,-839,-726
    -663,-800,-791
    -17,49,1
    -428,-762,319
    -452,-869,434
    806,-584,-592
    -468,406,-817
    118,-97,56
    530,403,850
    -433,399,-634
    521,-484,654
    881,-476,-533
    954,-520,-545
    781,439,-557
    609,-463,682
    -327,671,688
    -542,-771,-726
    -328,557,674
    661,-458,693
    510,298,863
    -240,536,611
    785,322,-393
    -432,416,-779
    -475,-744,471
    518,305,832
    823,411,-365

    --- scanner 11 ---
    -559,-302,-674
    -766,553,760
    -687,-322,850
    -800,-238,758
    370,-773,-566
    -851,883,-504
    -804,954,-655
    -716,-388,-711
    17,134,92
    884,-743,798
    905,900,-296
    -681,-359,-759
    -84,7,-30
    851,833,-390
    -756,459,918
    479,-816,-448
    -848,870,-519
    707,-731,809
    814,914,-406
    503,782,753
    544,911,722
    767,-719,748
    640,788,734
    572,-776,-603
    -781,-228,812
    -703,514,732

    --- scanner 12 ---
    -593,845,571
    -95,162,7
    -509,-378,-516
    504,-445,343
    -400,708,-674
    -554,-465,-583
    431,-519,471
    -473,-359,-516
    -592,828,716
    -931,-358,491
    -906,-487,413
    -628,838,754
    -487,573,-751
    370,841,-913
    625,922,330
    663,833,302
    429,-748,-651
    358,939,-895
    244,-687,-680
    -794,-417,415
    621,805,494
    350,946,-926
    351,-656,-694
    -488,687,-737
    575,-504,385

    --- scanner 13 ---
    -540,634,673
    764,-806,-384
    489,306,-588
    141,-5,-53
    577,221,-522
    -383,-685,663
    -575,616,539
    -558,-546,-541
    -444,-533,-673
    -356,-714,588
    -603,633,440
    791,-862,408
    763,728,555
    610,-722,-434
    758,-918,432
    693,-743,468
    -611,661,-390
    607,-706,-368
    -1,-144,-29
    -280,-701,796
    -706,583,-501
    -709,727,-493
    764,719,476
    763,692,397
    643,299,-606
    -566,-523,-601

    --- scanner 14 ---
    -636,680,-483
    718,525,642
    822,571,-429
    534,-636,-655
    -464,-684,-415
    34,31,141
    -600,748,862
    -629,673,889
    719,758,705
    -438,-516,679
    -448,-588,801
    780,425,-363
    -616,881,965
    467,-723,-700
    -462,-614,-303
    806,549,-467
    668,-416,539
    746,-305,634
    -461,-456,687
    701,624,670
    -795,747,-546
    -726,811,-463
    -540,-743,-278
    -82,-24,3
    812,-408,536
    467,-742,-736

    --- scanner 15 ---
    570,716,-401
    813,-522,-700
    -565,-663,616
    577,-384,448
    71,-43,-130
    -641,-610,619
    -731,-539,-421
    -448,392,521
    563,363,512
    -486,-548,601
    792,-612,-764
    638,513,555
    -760,-644,-580
    680,-591,-767
    533,452,650
    -701,454,-458
    698,-382,317
    -309,433,468
    576,631,-465
    -18,83,4
    -617,468,-599
    737,-417,381
    -678,-502,-550
    -643,510,-487
    595,735,-538
    -419,340,533

    --- scanner 16 ---
    -99,-26,105
    -171,-173,17
    -808,-569,-752
    -430,-810,823
    276,298,847
    -545,545,909
    406,-582,-466
    797,-624,681
    -592,481,-545
    -566,579,670
    483,-511,-365
    283,346,756
    390,447,-285
    766,-707,633
    341,480,-430
    -591,-585,-737
    814,-646,819
    -404,-880,890
    -381,-806,850
    -544,516,-546
    -514,646,760
    320,473,796
    -718,539,-542
    364,432,-384
    -684,-567,-828
    335,-604,-365

    --- scanner 17 ---
    -814,515,-501
    351,736,-672
    -840,-376,629
    -809,-483,615
    420,355,558
    452,-906,-323
    -512,341,793
    461,-873,-478
    534,356,572
    -618,422,726
    -901,-561,658
    -866,536,-417
    346,616,-702
    -798,-485,-246
    -31,-18,-10
    -785,-377,-340
    786,-490,414
    -885,-489,-394
    278,697,-583
    -163,40,154
    -828,605,-546
    -531,377,793
    555,268,635
    793,-482,383
    688,-502,396
    346,-856,-366

    --- scanner 18 ---
    -599,-418,-687
    485,631,359
    -642,-843,277
    894,-574,-927
    137,-133,-101
    -513,528,790
    -703,425,-406
    623,-464,487
    843,-793,-941
    616,-512,636
    -661,-584,-635
    857,650,-567
    765,-461,546
    -612,-497,-702
    -561,611,821
    -770,355,-380
    485,724,507
    929,-711,-860
    -699,589,838
    948,668,-660
    -730,429,-357
    -605,-829,293
    -24,-73,10
    586,653,430
    -757,-881,273
    872,666,-784

    --- scanner 19 ---
    805,-688,638
    106,-100,35
    673,664,467
    -736,-787,-834
    -702,-600,-813
    641,-450,-283
    561,430,-721
    -708,-739,-828
    571,-441,-459
    -562,-605,531
    -610,479,771
    590,617,600
    -611,307,692
    623,461,-542
    -300,636,-543
    755,-696,517
    -551,-598,488
    -557,-549,612
    -380,632,-579
    -77,14,78
    611,563,-698
    782,-698,664
    -396,723,-429
    546,708,493
    -539,440,712
    647,-455,-494

    --- scanner 20 ---
    -73,-55,-94
    679,574,-740
    412,-822,-515
    -380,370,-593
    587,593,879
    -693,453,644
    -818,416,667
    722,670,792
    450,-652,686
    608,656,791
    -288,297,-533
    457,-835,651
    -749,-809,456
    691,374,-778
    -793,-809,-818
    421,-914,-678
    113,-67,36
    -695,-740,-793
    467,-797,687
    -788,-744,476
    538,-900,-564
    -579,-816,-811
    662,430,-653
    -720,-744,577
    -333,306,-554
    -711,301,691

    --- scanner 21 ---
    -720,-494,-326
    -779,-506,-326
    725,743,-671
    643,-838,-672
    735,624,-742
    780,-444,760
    635,-395,727
    -773,-551,682
    523,664,668
    712,637,-797
    4,104,146
    -655,857,-500
    -883,800,504
    -152,-49,102
    -923,-626,725
    681,-418,775
    -827,-424,-336
    601,-802,-556
    520,538,726
    617,-733,-612
    -698,874,-492
    -834,-656,587
    -892,821,623
    519,490,691
    -920,866,-491
    -796,858,617

    --- scanner 22 ---
    80,-91,68
    564,449,615
    694,505,-425
    820,-741,761
    697,526,-537
    -542,-761,600
    -615,-889,674
    630,595,-404
    558,522,416
    -23,-171,-90
    635,-555,-793
    552,-486,-729
    -335,769,464
    464,420,470
    683,-817,702
    -344,568,399
    -75,6,7
    -833,-862,-867
    -686,-847,615
    -836,-696,-870
    615,-645,-662
    -348,698,547
    -518,733,-640
    795,-819,632
    -874,-749,-817
    -387,735,-519
    -451,700,-480

    --- scanner 23 ---
    -521,536,-591
    405,-522,-611
    598,-743,933
    739,728,856
    -767,828,470
    553,913,-698
    -311,-634,587
    808,645,792
    -303,-497,588
    -36,32,-25
    475,888,-569
    447,-593,-552
    -793,724,594
    533,-449,-537
    -589,-447,-308
    -454,455,-697
    649,708,725
    477,776,-639
    -632,-369,-400
    -809,762,616
    545,-781,880
    105,114,172
    -310,-582,457
    432,-740,930
    -618,-262,-369
    -454,491,-678

    --- scanner 24 ---
    -574,-700,-914
    645,309,-801
    511,564,648
    -735,664,363
    464,628,796
    703,-469,305
    691,-453,440
    -552,404,-633
    710,348,-821
    -763,685,451
    496,-926,-724
    702,-429,236
    -885,-631,405
    1,-36,-128
    452,672,723
    -672,-700,-757
    -928,-818,431
    -916,-845,434
    -515,279,-610
    515,-953,-752
    645,377,-700
    421,-973,-621
    -625,-803,-884
    -774,690,503
    -400,386,-586

    --- scanner 25 ---
    -660,-612,759
    44,-15,-25
    -564,539,589
    -501,550,610
    817,513,-563
    412,-387,533
    -535,416,-425
    -819,-717,730
    743,582,558
    666,604,559
    -690,-754,677
    790,542,-488
    836,-482,-889
    781,-535,-703
    -473,-665,-681
    -540,-734,-814
    -665,512,540
    -618,347,-489
    742,-472,-731
    341,-434,684
    425,-390,548
    593,616,664
    -555,506,-556
    -476,-644,-793
    893,526,-355

    --- scanner 26 ---
    283,522,745
    -873,247,471
    628,-379,499
    336,469,783
    -605,567,-596
    -904,279,268
    -675,529,-760
    -944,-764,-808
    -898,-880,692
    286,356,742
    -18,5,-170
    -93,-106,-29
    360,663,-726
    622,-869,-722
    -946,250,385
    759,-386,584
    -742,-793,-828
    629,-387,636
    -776,-774,753
    -830,-795,-768
    746,-843,-826
    600,-885,-760
    -654,540,-697
    424,732,-643
    491,573,-706
    -885,-685,732

    --- scanner 27 ---
    706,-520,-692
    -101,126,35
    771,564,-698
    -480,528,-493
    442,456,859
    559,502,806
    752,-472,-669
    514,541,941
    -584,455,-474
    -875,-543,521
    -499,391,-468
    -747,589,719
    771,471,-550
    -763,-660,-431
    726,-380,811
    -823,-531,550
    670,542,-627
    -782,-478,411
    677,-552,736
    675,-422,649
    851,-487,-643
    -702,-565,-536
    -852,-522,-461
    -43,-34,179
    -761,448,803
    -705,477,745

    --- scanner 28 ---
    573,505,-684
    8,-24,126
    428,-551,785
    857,610,665
    -56,144,29
    -507,671,603
    -723,-628,-438
    -717,-596,681
    850,592,511
    495,394,-589
    464,-393,785
    -586,488,-809
    -697,-643,701
    -698,573,-725
    429,497,-687
    523,-436,-581
    -702,-787,657
    -789,-593,-508
    -533,539,692
    935,526,599
    540,-535,-553
    -778,-650,-426
    -354,610,678
    116,29,-19
    522,-669,-518
    -553,559,-659
    437,-472,786

    --- scanner 29 ---
    683,-540,-630
    402,-538,-643
    -329,-493,653
    840,566,429
    722,647,510
    664,-649,866
    28,-140,-104
    878,620,-837
    -765,-884,-623
    732,696,-778
    -28,13,9
    -454,309,-532
    -327,-538,662
    948,661,-747
    -340,-585,849
    817,-625,774
    434,-525,-638
    865,-603,814
    -430,363,472
    900,551,520
    -446,294,528
    -808,-917,-481
    -563,315,-597
    -510,267,-682
    -758,-915,-590
    -404,258,412

    --- scanner 30 ---
    -299,482,-468
    753,540,-526
    737,658,-630
    835,-810,469
    -294,373,-321
    -718,-593,401
    -757,-504,474
    -637,-474,469
    -294,618,-363
    356,-836,-662
    -536,-675,-691
    680,719,-521
    505,718,872
    -589,832,666
    885,-853,575
    -532,795,629
    -626,-630,-705
    -56,-7,92
    385,591,857
    -380,769,678
    468,-782,-762
    517,481,906
    464,-930,-675
    -557,-759,-743
    852,-698,584

    --- scanner 31 ---
    -504,-722,764
    -471,-655,604
    620,778,-539
    -579,438,-698
    -750,-487,-538
    -649,474,-531
    -41,117,16
    305,-582,-421
    -635,-502,-459
    -524,762,878
    -469,-786,725
    276,-591,590
    365,-453,560
    420,460,710
    -635,417,-543
    372,470,792
    -182,-19,99
    253,-570,-392
    426,-548,665
    618,810,-537
    -697,-484,-614
    346,-635,-282
    479,460,722
    -606,786,771
    -653,734,906
    676,838,-365

    --- scanner 32 ---
    -839,-599,715
    351,-528,-912
    377,598,754
    -751,502,-745
    498,820,-545
    -631,-549,-889
    566,-519,640
    -706,-506,-739
    -862,-551,669
    -524,788,651
    332,607,752
    -149,64,-129
    -455,732,635
    -833,512,-793
    496,852,-547
    324,880,-489
    -419,848,677
    6,95,-6
    -763,502,-686
    479,-649,638
    380,-540,-860
    641,-691,689
    424,411,741
    241,-593,-819
    -601,-411,-800
    -813,-584,814
    """
    let scannerPositions: [[Float]] = [[-1325, -1205, -103],
                                       [-29, -1057, -105],
                                       [-86, 127, 1153],
                                       [-88, 81, -1292],
                                       [-18, 1198, -75],
                                       [-111, 2492, -12],
                                       [1140, 135, -1377],
                                       [-78, -1134, -1190],
                                       [-1191, -6, -1319],
                                       [-129, 2430, 1044],
                                       [1080, 2479, -57],
                                       [-109, 2416, -1228],
                                       [2447, 99, -1322],
                                       [1152, 1337, -1293],
                                       [2325, 2564, -142],
                                       [2303, 3720, -146],
                                       [31, 2493, 2288],
                                       [3, 3739, 1197],
                                       [-14, 113, 2259],
                                       [-53, 117, 3543],
                                       [1150, 2511, 2339],
                                       [-127, 2412, 3436],
                                       [-1149, -1171, -1360],
                                       [-1191, -2329, -1375],
                                       [-1216, -1120, -2416],
                                       [-18, 4915, 1074],
                                       [1085, -1120, -47],
                                       [-118, -2270, -157],
                                       [-45, -2280, 1019],
                                       [1117, -2390, -133],
                                       [-1160, -2231, 1123],
                                       [-2409, -2252, -1199]]
    let pairs = scannerPositions.combinations(count: 2)
    var maxD: Float = 0
    pairs.forEach({
        let md = abs($0[0][0] - $0[1][0]) + abs($0[0][1] - $0[1][1]) + abs($0[0][2] - $0[1][2])
        maxD = max(maxD, md)
    })

    print(maxD)
    assert(false)

    let scannersText = input.components(separatedBy: "\n\n")

    var scanners: [[simd_float4]] = []

    for text in scannersText {
        let coordsAsStrings = text.split(separator: "\n").suffix(from: 1)
        scanners.append(coordsAsStrings.map({ coord in
            let coordSplit = coord.split(separator: ",")
            return simd_float4(x: Float(coordSplit[0])!, y: Float(coordSplit[1])!, z: Float(coordSplit[2])!, w: 1)
        }))
    }

    var allBeacons: Set<simd_float4> = []

    var scannerCoordsInZeroSpace: [Int: [simd_float4]] = [0:scanners[0]]
    var done: Set<Int> = []
    while scannerCoordsInZeroSpace.count != scanners.count {
        let next = scannerCoordsInZeroSpace.filter({ !done.contains($0.key) }).first!
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

//    var base = scanners[0]
//    var nonBase = scanners[1]
//
//    var matching = getMatchingBeaconsBetween(baseScanner: base, nonBaseScanner: nonBase)
//    for c in matching!.allTransformedNonBaseCoordsIntoBaseSpace {
//        allBeacons.insert(c)
//    }
//    print("Scanner 1 is at inverse \(matching!.baseScannerPositionRelativeToNonBase) to 0")
//
//    base = matching!.allTransformedNonBaseCoordsIntoBaseSpace
//    for nonBaseIndex in 2..<scanners.count {
//        nonBase = scanners[nonBaseIndex]
//        if let matching = getMatchingBeaconsBetween(baseScanner: base, nonBaseScanner: nonBase) {
//            for c in matching.allTransformedNonBaseCoordsIntoBaseSpace {
//                allBeacons.insert(c)
//            }
//            print("Scanner \(nonBaseIndex) is at inverse \(matching.baseScannerPositionRelativeToNonBase) to 0")
//        } else {
//            print("Scanner \(nonBaseIndex) does not overlap with scanner 1")
//        }
//    }

    print(allBeacons.count)



    /*
     Loop through all scanners as a base scanner.
        Loop through all higher scanners as non-base scanners.
            If match is found, add relative scanner position to dict
     */
//    struct ScannerIndexPair: Hashable, CustomStringConvertible {
//        let baseScannerIndex: Int
//        let nonBaseScannerIndex: Int
//
//        var description: String {
//            "\(nonBaseScannerIndex) rel to \(baseScannerIndex)"
//        }
//    }
//    var relativeScannerPositionsAndRotations: [ScannerIndexPair: (nonBasePosition: simd_float4, rotationAppliedToNonBase: simd_float4x4)] = [:]
//
//    for i in 0..<scanners.count-1 {
//        for j in i+1..<scanners.count {
//            let matching = getMatchingBeaconsBetween(baseScanner: scanners[i], nonBaseScanner: scanners[j])
//            if let matching = matching {
//                let nonBaseScannerPositionRelativeToBase = matching.nonBaseScannerPosition
//                let pair = ScannerIndexPair(baseScannerIndex: i, nonBaseScannerIndex: j)
//                relativeScannerPositionsAndRotations[pair] = (nonBaseScannerPositionRelativeToBase, matching.rotationAppliedToNonBase)
//            }
//        }
//    }
//
//    print(relativeScannerPositionsAndRotations)
}

/// Will optionally return a translation that describes how to get the nonBaseScanner to the base
private func getMatchingBeaconsBetween(baseScanner: [simd_float4], nonBaseScanner: [simd_float4]) -> (nonBaseBeaconPositionsRelativeToBase: [simd_float4],
                                                                                                      baseScannerPositionRelativeToNonBase: simd_float4,
                                                                                                      rotationAppliedToNonBase: simd_float4x4,
                                                                                                      allTransformedNonBaseCoordsIntoBaseSpace: [simd_float4])? {
    // We need to go through all rotations and check whether the rotation ends up matching the coords
    for (rotationIndex, rotationMatrix) in RotationMatrixStore.allRotationMatrices.enumerated() {
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
            //            print("Pair: \(p)")
            let xDiff = p.1.x - p.0.x
            let yDiff = p.1.y - p.0.y
            let zDiff = p.1.z - p.0.z
            //            print("\tDifference: \(xDiff) \(yDiff) \(zDiff)")

            var matchingCoordCount = 0
            var matchingCoordsRelativeToNonBase: [simd_float4] = []
            var matchingCoordsRelativeToBase: [simd_float4] = []
            // For each coordinate in the non-base scanner, translate it by the difference.
            // If the translated coord is in the base scanner's coord set, increase the count
            for nonBaseCoord in scannerToCheckWithRotatedCoords {
                let translated = perform3DTranslation(origin: nonBaseCoord, tx: xDiff, ty: yDiff, tz: zDiff)
                //                print("\t\tTranslated: \(nonBaseCoord) -> \(translated)")
                if baseScanner.contains(translated) {
                    matchingCoordCount += 1
                    matchingCoordsRelativeToNonBase.append(nonBaseScanner[scannerToCheckWithRotatedCoords.firstIndex(of: nonBaseCoord)!])
                    matchingCoordsRelativeToBase.append(translated)
                }
            }

            //        print("\tOverlapping coord count: \(matchingCoordCount)")
            if matchingCoordCount >= 12 {
//                return (matchingCoordsRelativeToBase, simd_float4(x: xDiff, y: yDiff, z: zDiff, w: 1))
//                print("Matching coords relative to non-base:")
//                for m in matchingCoordsRelativeToNonBase { print("\t", m) }
//
//                print("Matching coords relative to base:")
//                for m in matchingCoordsRelativeToBase { print("\t", m) }
                let allNonBaseTransformed: [simd_float4] = nonBaseScanner.map({
                    let rotated = rotationMatrix * $0
                    let translated = perform3DTranslation(origin: rotated, tx: xDiff, ty: yDiff, tz: zDiff)
                    return translated
                })
                return (matchingCoordsRelativeToBase, simd_float4(x: xDiff, y: yDiff, z: zDiff, w: 1), rotationMatrix, allNonBaseTransformed)



//                print("Match found between scanners \(nonBaseStart - 1) and \(scannerToCheckIndex) with rotation index", rotationIndex)
//
//                let nonBaseScannerPosition = simd_float4(x: xDiff, y: yDiff, z: zDiff, w: 1)
//                print("Non-base scanner pos relative to base scanner: ", nonBaseScannerPosition)
//                allBeacons.append(contentsOf: matchingCoordsRelativeToBase)
//                baseScanner = allBeacons
//                nonBaseStart += 1
//                assert(false)
            }
        }
    }
    return nil
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

    /*
     When doing scanner 1 against scanner 0, we ended up rotating each coord in scanner 1 by:
     cols: [-1.0, 0.0, 0.0, 0.0], [0.0, 1.0, 0.0, 0.0], [0.0, 0.0, -1.0, 0.0], [0.0, 0.0, 0.0, 1.0]
     Then, we translated the rotated coords by 68.0, -1246.0, -43.0, 1.0.

     So, to translate ANY coord in s1 to s0, we rotate then translate

     Using 686,422,578 as an example:
     */

//    let example3d = simd_float4(x: 686, y: 422, z: 578, w: 1)
//    let rotationMatrix = simd_float4x4(rows: [
//        simd_float4(x: -1, y: 0, z:  0, w: 0),
//        simd_float4(x:  0, y: 1, z:  0, w: 0),
//        simd_float4(x:  0, y: 0, z: -1, w: 0),
//        simd_float4(x:  0, y: 0, z:  0, w: 1),
//    ])
//    let rotated = rotationMatrix * example3d
//    let translated = perform3DTranslation(origin: rotated, tx: 68, ty: -1246, tz: -43)
//    print(translated)

    // And now using 553, 889, -390 as an example
    let example3d = simd_float4(x: 553, y: 889, z: -390, w: 1)
    let rotationMatrix = simd_float4x4(rows: [
        simd_float4(x: -1, y: 0, z:  0, w: 0),
        simd_float4(x:  0, y: 1, z:  0, w: 0),
        simd_float4(x:  0, y: 0, z: -1, w: 0),
        simd_float4(x:  0, y: 0, z:  0, w: 1),
    ])
    let rotated = rotationMatrix * example3d
    let translated = perform3DTranslation(origin: rotated, tx: 68, ty: -1246, tz: -43)
    print(translated)
}

try main()
