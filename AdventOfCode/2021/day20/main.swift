import Foundation

let LIGHT_PIXEL: Character = "#"
let DARK_PIXEL: Character = "."

func main() throws {
    let input: [String] = try readInput(fromTestFile: false, separator: "\n\n")
    let imageEnhancementAlgorithm = [Character](input[0])

    var image = buildInitialImage(from: input[1])
    for _ in 0..<2 { image = image.process(using: imageEnhancementAlgorithm) }
    print("Part 1:", image.container.count)

    image = buildInitialImage(from: input[1])
    for _ in 0..<50 { image = image.process(using: imageEnhancementAlgorithm) }
    print("Part 2:", image.container.count)
}

struct Image {
    let state: State
    let container: Set<Coordinate>
    var nextState: State { state == .containingLightPixels ? .containingDarkPixels : .containingLightPixels }

    func process(using imageEnhancementAlgorithm: [Character]) -> Image {
        var outputContainer: Set<Coordinate> = []
        let bounds = getBounds()
        for y in bounds.y {
            for x in bounds.x {
                let coord = Coordinate(x, y)
                let adjacentsIncludingSelf = coord.getAdjacentsIncludingSelf()

                let binaryString = adjacentsIncludingSelf.map({ getBinaryChar(for: $0) }).joined()
                let decimal = Int(binaryString, radix: 2)!

                if state == .containingLightPixels {
                    // The next state will contain dark pixels
                    if imageEnhancementAlgorithm[decimal] == DARK_PIXEL {
                        outputContainer.insert(coord)
                    }
                } else {
                    // The next state will contain light pixels
                    if imageEnhancementAlgorithm[decimal] == LIGHT_PIXEL {
                        outputContainer.insert(coord)
                    }
                }
            }
        }
        return Image(state: nextState, container: outputContainer)
    }

    private func getBounds() -> (y: ClosedRange<Int>, x: ClosedRange<Int>) {
        let sortedByX = container.sorted(by: { $0.x < $1.x })
        let sortedByY = container.sorted(by: { $0.y < $1.y })

        return ((sortedByY[0].y-1)...(sortedByY.last!.y+1),(sortedByX[0].x-1)...(sortedByX.last!.x+1))
    }

    private func getBinaryChar(for coord: Coordinate) -> String {
        if state == .containingLightPixels {
            // State contains light pixels so we want to add a 1 if the container contains our coord
            return container.contains(coord) ? "1" : "0"
        } else {
            // State contains dark pixels so we want to add a 1 if the container contains our coord
            return container.contains(coord) ? "0" : "1"
        }
    }

    enum State {
        case containingLightPixels
        case containingDarkPixels
    }
}

private func buildInitialImage(from input: String) -> Image {
    let inputImage = input.split(separator: "\n").map({ [Character]($0) })

    var litPixels: Set<Coordinate> = []
    for y in 0..<inputImage.count {
        for x in 0..<inputImage[0].count {
            let coord = Coordinate(x, y)
            if inputImage[y][x] == LIGHT_PIXEL { litPixels.insert(coord) }
        }
    }

    return Image(state: .containingLightPixels, container: litPixels)
}

private func getBoundsToCheck(from litPixels: Set<Coordinate>) -> (yBounds: ClosedRange<Int>, xBounds: ClosedRange<Int>) {
    let sortedByX = litPixels.sorted(by: { $0.x < $1.x })
    let minX = sortedByX[0].x
    let maxX = sortedByX.last!.x

    let sortedByY = litPixels.sorted(by: { $0.y < $1.y })
    let minY = sortedByY[0].y
    let maxY = sortedByY.last!.y

    return ((minY-1)...(maxY+1),(minX-1)...(maxX+1))
}

try main()

