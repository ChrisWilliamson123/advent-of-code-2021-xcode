func dijkstra<T: Hashable>(graph: Set<T>,
                           source: T,
                           target: T?,
                           getNeighbours: (T) -> Set<T>,
                           getDistanceBetween: (T, T) -> Int) -> (distances: [T: Int], chain: [T: T?]) {
    var dist: [T: Int] = [:]
    var prev: [T: T?] = [:]
    var visited: Set<T> = []
    dist[source] = 0

    var heap = Heap<T>(priorityFunction: { dist[$0]! < dist[$1]! })

    for vertex in graph {
        if vertex != source {
            dist[vertex] = Int.max
            prev[vertex] = nil
        }
    }
    heap.enqueue(source)

    while !heap.isEmpty {
        let current = heap.dequeue()!
        if let target = target, current == target { return (dist, prev) }
        visited.insert(current)

        let neighbours = getNeighbours(current)
        for neighbour in neighbours where !visited.contains(neighbour) {
            let newDistance = dist[current]! + getDistanceBetween(current, neighbour)

            if newDistance < dist[neighbour, default: Int.max] {
                dist[neighbour] = newDistance
                prev[neighbour] = current
                if heap.indexMap[neighbour] != nil {
                    heap.changeElement(neighbour, to: neighbour)
                } else {
                    heap.enqueue(neighbour)
                }
            }
        }
    }

    return (dist, prev)
}
