import Foundation

func main() throws {
    let input: [String] = try readInput(fromTestFile: false)
    let containers: [Container] = input.enumerated().map({ (index, inputLine) in
        return Container(capacity: Int(inputLine)!, id: index)
    })
    let litresToStore: Int = 150
    var subsets: Set<Set<Container>> = []
    func subset_sum(numbers: [Container], target: Int, partial: [Container] = []) {
        let sum = partial.map({$0.capacity}).sum()
        if sum == target {
            subsets.insert(Set(partial))
        }
        if sum >= target {
            return
        }
        for i in 0..<numbers.count {
            let n = numbers[i]
            let remaining = numbers[i+1..<numbers.count]
            subset_sum(numbers: Array(remaining), target: target, partial: partial + [n])
        }
    }

    subset_sum(numbers: containers, target: litresToStore)
    print("Part one:", subsets.count)
    let minimumNumberOfContainersUsed = subsets.map({ $0.count }).min()!
    let subsetsWithMinUsed = subsets.filter({ $0.count == minimumNumberOfContainersUsed }).count
    print("Part two:", subsetsWithMinUsed)
}

struct Container: Hashable {
    let capacity: Int
    let id: Int
}

Timer.time(main)
