import Foundation

enum Command {
    case changeDir(name: String)
    case list

    static func initialise(string: String) -> Command {
        let raw = string.replacingOccurrences(of: "$ ", with: "")
        if raw.starts(with: "cd") {
            return .changeDir(name: String(raw.split(separator: " ")[1]))
        } else {
            return .list
        }
    }
}

func main() throws {
    let input: [String] = try readInput(fromTestFile: false)

    var topDir = Directory(name: "/")
    var currentDirectory: Directory = topDir
    var lineIndex = 1
    var directories: [Directory] = [currentDirectory]
    while lineIndex < input.count {
        let line = input[lineIndex]
        let command = Command.initialise(string: line)
        if case let .changeDir(name) = command {
            if name == ".." {
                currentDirectory = currentDirectory.parent!
            } else {
                if let existingDirectory = currentDirectory.contents.first(where: { $0.name == name }) as? Directory {
                    currentDirectory = existingDirectory
                } else {
                    assertionFailure("cd target doesn't exists")
                }
            }
            lineIndex += 1
            continue
        } else {
            let endOfListOutputIndex = ((lineIndex+1..<input.count).first(where: { input[$0].starts(with: "$") }) ?? input.count) - 1
            let newDirs = currentDirectory.createContents(from: Array(input[lineIndex+1...endOfListOutputIndex]))
            directories.append(contentsOf: newDirs)
            lineIndex = endOfListOutputIndex + 1
            continue
        }
    }
    let sizes = directories.map { $0.size }
    print(sizes.reduce(0, {
        if $1 < 100000 {
            return $0 + $1
        } else {
            return $0
        }
    }))
//    print(sum)

    let unusedSpace = 70000000 - directories[0].size
    let deletionNeeded = 30000000 - unusedSpace
    print(unusedSpace, deletionNeeded)
    let deletionCandidates = sizes.filter({ $0 >= deletionNeeded })
    print(deletionCandidates.sorted())
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
    var size: Int {
        let size = contents.map({ $0.size }).sum()
//        print("\(name) size: \(size)")
        return size
    }
    var contents: [Entity] = []
    var parent: Directory?

    init(name: String) {
        self.name = name
    }

    func createContents(from lines: [String]) -> [Directory] {
        var newDirs: [Directory] = []
        for l in lines {
            if l.starts(with: "dir") {
                let dir = Directory(name: l.replacingOccurrences(of: "dir ", with: ""))
                dir.parent = self
                contents.append(dir)
                newDirs.append(dir)
            } else {
                let name = String(String(l.split(separator: " ")[1]))
                if contents.contains(where: { $0.name == name }) { continue }
                contents.append(File(name: name, size: Int(l.split(separator: " ")[0])!))
            }
        }
        return newDirs
    }
}

try main()
