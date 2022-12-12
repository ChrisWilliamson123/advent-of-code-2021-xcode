//
//  BFS.swift
//  AdventOfCode
//
//  Created by Chris Williamson on 12/12/2022.
//

import Foundation

/**
 Gets the shortest distance from a single source node to the target node.
 Returns -1 if no path was found
 */
func bfs<T: Hashable>(graph: Set<T>,
                      source: T,
                      target: T,
                      getNeighbours: (T) -> Set<T>,
                      getDistanceBetween: (T, T) -> Int) -> Int {
    bfs(graph: graph, source: [source], target: [target], getNeighbours: getNeighbours, getDistanceBetween: getDistanceBetween)
}

/**
 Gets the shortest distance from any source node to the target node.
 Returns -1 if no path was found
 */
func bfs<T: Hashable>(graph: Set<T>,
                      source: Set<T>,
                      target: T,
                      getNeighbours: (T) -> Set<T>,
                      getDistanceBetween: (T, T) -> Int) -> Int {
    bfs(graph: graph, source: source, target: [target], getNeighbours: getNeighbours, getDistanceBetween: getDistanceBetween)
}

/**
 Gets the shortest distance from a single source node to any target node.
 Returns -1 if no path was found
 */
func bfs<T: Hashable>(graph: Set<T>,
                      source: T,
                      target: Set<T>,
                      getNeighbours: (T) -> Set<T>,
                      getDistanceBetween: (T, T) -> Int) -> Int {
    bfs(graph: graph, source: [source], target: target, getNeighbours: getNeighbours, getDistanceBetween: getDistanceBetween)
}

/**
 Gets the shortest distance from any source node to any target node.
 Returns -1 if no path was found
 */
func bfs<T: Hashable>(graph: Set<T>,
                      source: Set<T>,
                      target: Set<T>,
                      getNeighbours: (T) -> Set<T>,
                      getDistanceBetween: (T, T) -> Int) -> Int {
    var queue = source.map { ($0, 0) }
    var visited: Set<T> = []
    while !queue.isEmpty {
        let (coord, distance) = queue.popLast()!
        if visited.contains(coord) { continue }
        visited.insert(coord)

        if target.contains(coord) { return distance }

        getNeighbours(coord).forEach { neighbour in
            queue.insert((neighbour, distance + getDistanceBetween(coord, neighbour)), at: 0)
        }
    }
    return -1
}
