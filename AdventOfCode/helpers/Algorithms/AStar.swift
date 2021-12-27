func aStar<T: Hashable>(graph: Set<T>,
                        source: T,
                        target: T,
                        getNeighbours: (T) -> Set<T>,
                        getDistanceBetween: (T, T) -> Int,
                        heuristicFunction: (T, T) -> Int) -> (distances: [T: Int], chain: [T: T?]) {
    var prev: [T: T?] = [:]
    var dist: [T: Int] = [:]

    for vertex in graph {
        if vertex != source {
            dist[vertex] = Int.max
            prev[vertex] = nil
        }
    }

    dist[source] = 0

    var fScore: [T: Int] = [:]
    fScore[source] = heuristicFunction(source, target)
    var queue = Heap(elements: [], priorityFunction: { fScore[$0]! < fScore[$1]! })
    queue.enqueue(source)

    while !queue.isEmpty {
        let current = queue.dequeue()!
        if current == target { return (dist, prev) }

        for n in getNeighbours(current) {
            let tentativeGScore = dist[current]! + getDistanceBetween(current, n)
            if tentativeGScore < dist[n]! {
                prev[n] = current
                dist[n] = tentativeGScore
                fScore[n] = tentativeGScore + heuristicFunction(n, target)

                if queue.indexMap[n] != nil {
                    queue.changeElement(n, to: n)
                } else {
                    queue.enqueue(n)
                }
            }
        }
    }

    assert(false, "Destination node not found")
}
