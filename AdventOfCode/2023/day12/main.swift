import Foundation
import Algorithms

func replaceInString(string: String, new: Character, location: Int) -> String {
    var toReturn = [Character](string)
    toReturn[location] = new
    return String(toReturn)
}

// Returns num
private func solve(line: String, index: Int, groups: [Int], groupIndex: Int) -> Set<String> {
//    print(line, index, groups)
    let hasFinishedLine = index >= line.count
    
    if hasFinishedLine {
        return groups.isEmpty ? [line] : []
    }
    
    let currentCharacter: Character = line[index]
    
    if currentCharacter == "." { return solve(line: line, index: index + 1, groups: groups, groupIndex: groupIndex) }
    
    if currentCharacter == "#" {
        if groups.isEmpty {
            return []
        }
        
        var newGroups = groups
        newGroups[groupIndex] -= 1
        let hashesLeftInGroup = newGroups[groupIndex]
        if hashesLeftInGroup > 0 {
            return solve(line: line, index: index + 1, groups: newGroups, groupIndex: groupIndex)
        } else {
            // Finished a group, check next char
            newGroups.remove(at: 0)
            let nextIndex = index + 1
            if nextIndex >= line.count {
                return solve(line: line, index: nextIndex, groups: newGroups, groupIndex: groupIndex)
            } else {
                // Next char is in line
                let nextChar: Character = line[nextIndex]
                if nextChar == "#" { return [] }
                if nextChar == "?" {
                    // skip over the ? as it needs to be treated as a dot
                    return solve(line: replaceInString(string: line, new: ".", location: nextIndex), index: nextIndex + 1, groups: newGroups, groupIndex: groupIndex)
                }
                return solve(line: line, index: nextIndex, groups: newGroups, groupIndex: groupIndex)
            }
        }
    }
    
    if currentCharacter == "?" {
        // If groups are done, treat as a dot
        if groups.isEmpty {
            return solve(line: replaceInString(string: line, new: ".", location: index), index: index + 1, groups: groups, groupIndex: groupIndex)
        }
        
        // if prev is hash, and group is not done, use hash
        if index > 0 {
            let prevChar: Character = line[index-1]
            if prevChar == "#" && groups[0] > 0 {
                var newGroups = groups
                newGroups[groupIndex] -= 1
                let hashesLeftInGroup = newGroups[groupIndex]
                if hashesLeftInGroup > 0 {
                    return solve(line: replaceInString(string: line, new: "#", location: index), index: index + 1, groups: newGroups, groupIndex: groupIndex)
                } else {
                    // Finished a group, check next char
                    newGroups.remove(at: 0)
                    let nextIndex = index + 1
                    if nextIndex >= line.count {
                        return solve(line: replaceInString(string: line, new: "#", location: index), index: nextIndex, groups: newGroups, groupIndex: groupIndex)
                    } else {
                        // Next char is in line
                        let nextChar: Character = line[nextIndex]
                        if nextChar == "#" { }
                        else if nextChar == "?" {
                            // skip over the ? as it needs to be treated as a dot
                            var newString = replaceInString(string: line, new: "#", location: index)
                            newString = replaceInString(string: newString, new: ".", location: nextIndex)
                            return solve(line: newString, index: nextIndex + 1, groups: newGroups, groupIndex: groupIndex)
                            
                        } else {
                            return solve(line: replaceInString(string: line, new: "#", location: index), index: nextIndex, groups: newGroups, groupIndex: groupIndex)
                        }
                    }
                }
            }
        }
        
        // groups are not done, treat as hash and dot
        var total: Set<String> = []
        
        var newGroups = groups
        newGroups[groupIndex] -= 1
        let hashesLeftInGroup = newGroups[groupIndex]
        if hashesLeftInGroup > 0 {
            total = total.union(solve(line: replaceInString(string: line, new: "#", location: index), index: index + 1, groups: newGroups, groupIndex: groupIndex))
        } else {
            // Finished a group, check next char
            newGroups.remove(at: 0)
            let nextIndex = index + 1
            if nextIndex >= line.count {
                total = total.union(solve(line: replaceInString(string: line, new: "#", location: index), index: nextIndex, groups: newGroups, groupIndex: groupIndex))
            } else {
                // Next char is in line
                let nextChar: Character = line[nextIndex]
                if nextChar == "#" { }
                else if nextChar == "?" {
                    // skip over the ? as it needs to be treated as a dot
                    var newString = replaceInString(string: line, new: "#", location: index)
                    newString = replaceInString(string: newString, new: ".", location: nextIndex)
                    total = total.union(solve(line: newString, index: nextIndex + 1, groups: newGroups, groupIndex: groupIndex))
                    
                } else {
                    total = total.union(solve(line: replaceInString(string: line, new: "#", location: index), index: nextIndex, groups: newGroups, groupIndex: groupIndex))
                }
            }
        }
        
        total = total.union(solve(line: replaceInString(string: line, new: ".", location: index), index: index + 1, groups: groups, groupIndex: groupIndex))
        
        return total
        
    }
    
    assert(false, "unknown char found")
}

func main() throws {
    let input: [String] = try readInput(fromTestFile: false, separator: "\n")
    var tot = 0
    for line in input {
        let split = line.split(separator: " ")
        let record = split[0]
        let groups = split[1].split(separator: ",").map({ Int($0)! })
//        print(record, groups)
        let result = solve(line: String(record), index: 0, groups: groups, groupIndex: 0)
        tot += result.count
    }
    
    print(tot)
}


Timer.time(main)
