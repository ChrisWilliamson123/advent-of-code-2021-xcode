struct Stack<T> {
    private var contents: [T]

    var all: [T] { contents }

    init(_ initialState: [T] = []) {
        self.contents = initialState
    }

    mutating func push(_ item: T) {
        contents.append(item)
    }

    @discardableResult
    mutating func pop() -> T? {
        contents.removeLast()
    }

    func peek() -> T? {
        contents.last
    }
}
