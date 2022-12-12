//
//  BFS.swift
//  AdventOfCode
//
//  Created by Chris Williamson on 12/12/2022.
//

import Foundation

func bfs<T: Hashable>(graph: Set<T>,
                      source: [T],
                      target: T?,
                      getNeighbours: (T) -> Set<T>,
                      getDistanceBetween: (T, T) -> Int) -> Int {
    var queue = source.map { ($0, 0) }
    var visited: Set<T> = []
    while !queue.isEmpty {
        let (coord, distance) = queue.popLast()!
        if visited.contains(coord) { continue }
        visited.insert(coord)

        if coord == target { return distance }

        getNeighbours(coord).forEach { neighbour in
            queue.insert((neighbour, distance + getDistanceBetween(coord, neighbour)), at: 0)
        }
    }
    return -1
}
