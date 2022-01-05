import Foundation

func main() throws {
    let instructions: [String] = try readInput(fromTestFile: false)

    var a = 1
    var b = 0
    var ip = 0

    while ip >= 0 && ip < instructions.count {
        let i = instructions[ip]
        let split = i.split(separator: " ")
        print(split, ip, a, b)
        switch split[0] {
        case "hlf":
            if split[1] == "a" {
                a /= 2
            } else {
                b /= 2
            }
            ip += 1
        case "tpl":
            if split[1] == "a" {
                a *= 3
            } else {
                b *= 3
            }
            ip += 1
        case "inc":
            if split[1] == "a" {
                a += 1
            } else {
                b += 1
            }
            ip += 1
        case "jmp":
            ip += Int(split[1])!
        case "jie":
            if split[1] == "a," {
                if a % 2 == 0 { ip += Int(split[2])! }
                else { ip += 1 }
            } else {
                if b % 2 == 0 { ip += Int(split[2])! }
                else { ip += 1 }
            }
        case "jio":
            if split[1] == "a," {
                if a == 1 { ip += Int(split[2])! }
                else { ip += 1 }
            } else {
                if b == 1 { ip += Int(split[2])! }
                else { ip += 1 }
            }
        default:
            assert(false)
        }
    }

    print(a, b)
}

try main()
