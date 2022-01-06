import Foundation

func main() throws {
    var last = 20151125
    var numbers: [Int] = [last]
    for i in 0..<25000000 {
        if i % 1000000 == 0 {
            print(i)
        }
        let next = (last * 252533) % 33554393
        numbers.append(next)
        last = next
    }

    print(numbers[getIndex(x: 3074, y: 2980)])
//    print(getIndex(x: 0, y: 0))
//
//    print(getIndex(x: 3, y: 1))
}

private func getIndex(x: Int, y: Int) -> Int {
    let n = x + y
    let base = (n*(n+1))/2
    return base + x
}

try main()
