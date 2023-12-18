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
                      target: T?,
                      getNeighbours: (T) -> Set<T>,
                      getDistanceBetween: (T, T) -> Int) -> (distances: [T: Int], prev: [T: T]) {
    bfs(graph: graph,
        source: [source],
        target: target.map { [$0] },
        getNeighbours: getNeighbours,
        getDistanceBetween: getDistanceBetween)
}

/**
 Gets the shortest distance from any source node to the target node.
 Returns -1 if no path was found
 */
func bfs<T: Hashable>(graph: Set<T>,
                      source: Set<T>,
                      target: T?,
                      getNeighbours: (T) -> Set<T>,
                      getDistanceBetween: (T, T) -> Int) -> (distances: [T: Int], prev: [T: T]) {
    bfs(graph: graph, source: source, target: target.map { [$0] }, getNeighbours: getNeighbours, getDistanceBetween: getDistanceBetween)
}

/**
 Gets the shortest distance from a single source node to any target node.
 Returns -1 if no path was found
 */
func bfs<T: Hashable>(graph: Set<T>,
                      source: T,
                      target: Set<T>?,
                      getNeighbours: (T) -> Set<T>,
                      getDistanceBetween: (T, T) -> Int) -> (distances: [T: Int], prev: [T: T]) {
    bfs(graph: graph, source: [source], target: target, getNeighbours: getNeighbours, getDistanceBetween: getDistanceBetween)
}

/**
 Gets the distances between a set of source nodes and an optional set of target nodes.
 Returns when the shortest distance has been found between and source node to any target node.
 Returns a dictionary which maps each visited coordinate to it's shortest distance from any source.
 */
func bfs<T: Hashable>(graph: Set<T>,
                      source: Set<T>,
                      target: Set<T>?,
                      getNeighbours: (T) -> Set<T>,
                      getDistanceBetween: (T, T) -> Int) -> (distances: [T: Int], prev: [T: T]) {

    var queue = source.map { ($0, 0) }
    var distances: [T: Int] = [:]
    queue.forEach({ distances[$0.0] = 0 })
    var visited: Set<T> = []
    var prev: [T: T] = [:]
    while !queue.isEmpty {
        let (coord, distance) = queue.popLast()!
        if visited.contains(coord) { continue }
        visited.insert(coord)

        if let target = target, target.contains(coord) { return (distances, prev) }
        let neighbours = getNeighbours(coord).filter({ !visited.contains($0) })

        neighbours.forEach { neighbour in
            let newDistance = distance + getDistanceBetween(coord, neighbour)
            queue.insert((neighbour, newDistance), at: 0)
            distances[neighbour] = min(distances[neighbour] ?? Int.max, newDistance)
            prev[neighbour] = coord
        }
    }
    return (distances, prev)
}
