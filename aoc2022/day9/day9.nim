import std/[sequtils, strutils, sugar, strscans, sets]


const TEST_INPUT = readFile("day9/test_input.txt")

const REAL_INPUT = readFile("day9/real_input.txt")

type
    Direction {.pure.} = enum
        DOWN = 'D', LEFT = 'L' , RIGHT = 'R', UP = 'U',

type Movement = tuple
    direction: Direction
    distance: int

type Coord = tuple
    x: int
    y: int

proc part1(instr: string): int =
    # y, x
    var headPosition = @[0, 0]
    var tailPosition = @[0, 0]
    let movements: seq[Movement] = 
        TEST_INPUT
            .splitLines()
            .map(line => scanTuple(line, "$c $i"))
            .map(t => (Direction(t[1]), t[2]))
    
    let tailCoveredPositions = initHashSet[Coord]()
    for i, (direction, distance) in movements:
        let factors: (int, int) = case(direction):
                of Down: (-1, 0)
                of Up: (1, 0)
                of Left: (0, -1)
                of Right: (0, 1)

        if i == 0:
            (headPosition[0], headPosition[1]) = (factors[0] * distance, factors[1] * distance)
            tailPosition[0] = (-1 * factors[0]) + headPosition[0]
            tailPosition[1] = (-1 * factors[1]) + headPosition[1]
            continue

        # horizontal movment
        if headPosition[]

        

    
    return tailCoveredPositions.len


proc main() =
    echo part1(TEST_INPUT)

main()