struct Heap<T: Hashable> {
    var elements: [T]
    /// Returns true if the first element has a higher priority than the second
    let priorityFunction: (T, T) -> Bool
    var indexMap: [T: Int] = [:]

    var isEmpty: Bool { elements.isEmpty }
    var count: Int { elements.count }

    init(elements: [T] = [], priorityFunction: @escaping (T, T) -> Bool) {
        self.elements = elements
        self.priorityFunction = priorityFunction
        elements.enumerated().forEach({ indexMap[$1] = $0 })
        buildHeap()
    }

    mutating func buildHeap() {
        for index in (0..<(count / 2)).reversed() {
            siftDown(elementAtIndex: index)
        }
    }

    func peek() -> T? {
        elements.first
    }

    mutating func enqueue(_ element: T) {
        elements.append(element)
        let count = count
        indexMap[element] = count-1
        siftUp(elementAtIndex: count-1)
    }

    mutating func siftUp(elementAtIndex index: Int) {
        let parent = parentIndex(of: index)
        guard !isRoot(index), isHigherPriority(at: index, than: parent) else { return }
        swapElement(at: index, with: parent)
        siftUp(elementAtIndex: parent)
    }

    mutating func dequeue() -> T? {
        guard !isEmpty else { return nil }
        swapElement(at: 0, with: count - 1)
        let element = elements.removeLast()
        indexMap[element] = nil
        if !isEmpty {
            siftDown(elementAtIndex: 0)
        }
        return element
    }

    mutating func siftDown(elementAtIndex index: Int) {
        let childIndex = highestPriorityIndex(for: index)
        if index == childIndex { return }
        swapElement(at: index, with: childIndex)
        siftDown(elementAtIndex: childIndex)
    }

    func isRoot(_ index: Int) -> Bool {
        index == 0
    }

    func leftChildIndex(of index: Int) -> Int {
        (2 * index) + 1
    }

    func rightChildIndex(of index: Int) -> Int {
        (2 * index) + 2
    }

    func parentIndex(of index: Int) -> Int {
        (index - 1) / 2
    }

    func isHigherPriority(at firstIndex: Int, than secondIndex: Int) -> Bool {
        priorityFunction(elements[firstIndex], elements[secondIndex])
    }

    func highestPriorityIndex(of parentIndex: Int, and childIndex: Int) -> Int {
        guard childIndex < count else { return parentIndex }
        return isHigherPriority(at: childIndex, than: parentIndex) ? childIndex : parentIndex
    }

    func highestPriorityIndex(for parent: Int) -> Int {
        highestPriorityIndex(of: highestPriorityIndex(of: parent, and: leftChildIndex(of: parent)),
                             and: rightChildIndex(of: parent))
    }

    mutating func swapElement(at firstIndex: Int, with secondIndex: Int) {
        if firstIndex == secondIndex { return }
        let a = elements[firstIndex]
        let b = elements[secondIndex]
        elements.swapAt(firstIndex, secondIndex)
        indexMap[a] = secondIndex
        indexMap[b] = firstIndex
    }

    mutating func changeElement(_ oldElement: T, to newElement: T) {
        let index = indexMap[oldElement]!
        elements[index] = newElement
        let parentIndex = parentIndex(of: index)
        if highestPriorityIndex(of: parentIndex, and: index) == index {
            siftUp(elementAtIndex: index)
        } else {
            siftDown(elementAtIndex: index)
        }
    }
}
