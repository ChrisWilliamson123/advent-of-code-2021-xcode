//import Foundation
//
//func main() throws {
//    let input: [String] = try readInput(fromTestFile: true, separator: "\n")
//    // Find the loop coords
//    
//    var coordsToChars: [Coordinate: Character] = [:]
//    var grid: [[Character]] = []
//    
//    for (y, line) in input.enumerated() {
//        var row: [Character] = []
//        for (x, char) in line.enumerated() {
//            let coord = Coordinate(x, y)
//            coordsToChars[coord] = char
//            row.append(char)
//        }
//        grid.append(row)
//    }
//    
//    let startLoopCoord = coordsToChars.first(where: { $0.value == "S" })!.key
//    let coords = Set(coordsToChars.keys)
//    print(startLoopCoord)
//    
//    let path = dijkstra(graph: coords,
//                        source: startLoopCoord,
//                        target: Coordinate(0, 0)) { currentCoord in
////        print("CC: \(coordsToChars[currentCoord])")
//        var neighbours = Set<Coordinate>()
//        let adjacents = currentCoord.getAdjacents(in: grid).compactMap({ ($0, coordsToChars[$0]) })
//        for a in adjacents {
//            let upCoord = currentCoord + Coordinate(0, -1)
//            if a.0 == upCoord && ["|", "7", "F"].contains(a.1) && ["|", "J", "L", "S"].contains(coordsToChars[currentCoord]) {
//                neighbours.insert(a.0)
//            }
//            let downCoord = currentCoord + Coordinate(0, 1)
//            if a.0 == downCoord && ["|", "L", "J"].contains(a.1) && ["|", "F", "7", "S"].contains(coordsToChars[currentCoord]) {
//                neighbours.insert(a.0)
//            }
//            let rightCoord = currentCoord + Coordinate(1, 0)
//            if a.0 == rightCoord && ["-", "7", "J"].contains(a.1) && ["-", "L", "F", "S"].contains(coordsToChars[currentCoord]) {
//                neighbours.insert(a.0)
//            }
//            let leftCoord = currentCoord + Coordinate(-1, 0)
//            if a.0 == leftCoord && ["-", "L", "F"].contains(a.1) && ["-", "J", "7", "S"].contains(coordsToChars[currentCoord]) {
//                neighbours.insert(a.0)
//            }
//        }
//        return neighbours
//        
//    } getDistanceBetween: { _, _ in
//        1
//    }
//    
//    print(path.distances.values.filter( { $0 != Int.max } ).max()!)
////    exit(0)
//    
//    let visitable = Set(Set(Array(path.chain.keys)).union(Set(path.chain.values)).compactMap({ $0 }))
//    
//    for (y, row) in grid.enumerated() {
//        var rowString = ""
//        for (x, char) in row.enumerated() {
//            let coord = Coordinate(x, y)
//            rowString += "\(visitable.contains(coord) ? "#" : ".")"
//        }
//        print(rowString)
//    }
//    exit(0)
//    print(visitable.count)
//    var maxDistance = 0
//    var contained: [Coordinate] = []
//    var done = 0
//    let toLoop = coords.filter({ coordsToChars[$0] != "S" && !visitable.contains($0) })
//    print(toLoop.count)
//    var index = 0
//    for c in toLoop {
//        print(c, index)
////        print(done)
////        print(v)
//        let path = dijkstra(graph: coords,
//                            source: c,
//                            target: Coordinate(0, 0)) { currentCoord in
////            var neighbours = Set<Coordinate>()
//            let adjacents = Set(currentCoord.getAdjacents(xBounds: -1...grid[0].count, yBounds: -1...grid.count))
//            if c == Coordinate(3, 2) {
//                
//                print(c, adjacents.subtracting(visitable))
//            }
//            return adjacents.subtracting(visitable)
////            let adjacents = currentCoord.getAxialAdjacents(in: grid).compactMap({ ($0, coordsToChars[$0]) })
////            for a in adjacents {
////                let upCoord = currentCoord + Coordinate(0, -1)
////                if a.0 == upCoord && ["|", "7", "F"].contains(a.1) && ["|", "J", "L", "S"].contains(coordsToChars[currentCoord]) {
////                    neighbours.insert(a.0)
////                }
////                let downCoord = currentCoord + Coordinate(0, 1)
////                if a.0 == downCoord && ["|", "L", "J"].contains(a.1) && ["|", "F", "7", "S"].contains(coordsToChars[currentCoord]) {
////                    neighbours.insert(a.0)
////                }
////                let rightCoord = currentCoord + Coordinate(1, 0)
////                if a.0 == rightCoord && ["-", "7", "J"].contains(a.1) && ["-", "L", "F", "S"].contains(coordsToChars[currentCoord]) {
////                    neighbours.insert(a.0)
////                }
////                let leftCoord = currentCoord + Coordinate(-1, 0)
////                if a.0 == leftCoord && ["-", "L", "F"].contains(a.1) && ["-", "J", "7", "S"].contains(coordsToChars[currentCoord]) {
////                    neighbours.insert(a.0)
////                }
////            }
////            return neighbours
//            
//        } getDistanceBetween: { _, _ in
//            1
//        }
////        print(c, path.distances[Coordinate(0, 0)])
//        if path.distances[Coordinate(0, 0)] == Int.max {
////            print("hello")
////            print(c)
//            print("Adding \(c)")
//            contained.append(c)
//        }
//        done += 1
//        index += 1
//    }
//    
////    print(maxDistance)
//    print("p2", contained.filter({ !visitable.contains($0) }).count)
//    print(contained)
//
//}
//
//Timer.time(main)
