import Foundation

func main() throws {
    let input: [String] = try readInput(fromTestFile: false)

    var currentDirectory: Directory = Directory(name: "/")
    var lineIndex = 1
    var directories: [Directory] = [currentDirectory]

    while lineIndex < input.count {
        let line = input[lineIndex]
        let command = Command.initialise(string: line)
        switch command {
        case .upDir:
            currentDirectory = currentDirectory.parent!
            lineIndex += 1
        case .changeDir(let name):
            let existingDirectory = currentDirectory.contents.first(where: { $0.name == name })! as! Directory
            currentDirectory = existingDirectory
            lineIndex += 1
        case .list:
            let endOfListOutputIndex = ((lineIndex+1..<input.count).first(where: { input[$0].starts(with: "$") }) ?? input.count) - 1
            let newDirs = currentDirectory.createContents(from: Array(input[lineIndex+1...endOfListOutputIndex]))
            directories.append(contentsOf: newDirs)
            lineIndex = endOfListOutputIndex + 1
        }
    }

    let sizes = directories.map { $0.size }
    print(sizes.reduce(0, { $1 < 100000 ? $0 + $1 : $0 }))

    let unusedSpace = 70000000 - directories[0].size
    let deletionNeeded = 30000000 - unusedSpace
    let deletionCandidates = sizes.filter({ $0 >= deletionNeeded })
    print(deletionCandidates.min()!)
}

enum Command {
    case upDir
    case changeDir(name: String)
    case list

    static func initialise(string: String) -> Command {
        if string.contains("..") { return .upDir }
        if string.contains("cd") { return .changeDir(name: String(string.split(separator: " ").last!)) }
        return .list
    }
}

protocol Entity {
    var name: String { get }
    var size: Int { get }
}

class File: Entity {
    let name: String
    let size: Int

    init(name: String, size: Int) {
        self.name = name
        self.size = size
    }
}

class Directory: Entity {
    let name: String
    var size: Int { contents.reduce(0, { $0 + $1.size }) }
    var contents: [Entity] = []
    var parent: Directory?
    var directories: [Directory] { contents.compactMap({ $0 as? Directory }) }

    init(name: String) {
        self.name = name
    }

    func createContents(from lines: [String]) -> [Directory] {
        for l in lines {
            if l.starts(with: "dir") {
                let dir = Directory(name: l.replacingOccurrences(of: "dir ", with: ""))
                dir.parent = self
                contents.append(dir)
            } else {
                let split = l.split(separator: " ")
                contents.append(File(name: String(split[1]), size: Int(split[0])!))
            }
        }
        return directories
    }
}

try main()
