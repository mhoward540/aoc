import std/[strutils, parseutils, strscans]


const TEST_INPUT = """A Y
B X
C Z"""

const REAL_INPUT = readFile("day2/real_input.txt")

type
    HandShape {.pure.} = enum
        ROCK = 1'i8, PAPER = 2'i8, SCISSORS = 3'i8
    Result {.pure.} = enum
        LOSS = 0'i8, DRAW = 3'i8, WIN = 6'i8

# y coordinate is opponent move, x coordinate is my move
const scoreMatrix = @[
    @[ord(DRAW) + ord(ROCK), ord(WIN)  + ord(PAPER), ord(LOSS) + ord(SCISSORS)],
    @[ord(LOSS) + ord(ROCK), ord(DRAW) + ord(PAPER), ord(WIN)  + ord(SCISSORS)],
    @[ord(WIN)  + ord(ROCK), ord(LOSS) + ord(PAPER), ord(DRAW) + ord(SCISSORS)]
]

# y coordinate is opponent move, x coordinate is result
const otherMatrix = @[
    @[SCISSORS, ROCK, PAPER], # opp rock
    @[ROCK, PAPER, SCISSORS], # opp paper
    @[PAPER, SCISSORS, ROCK] # opp scissors
]

func mapHandShape(c: char): HandShape =
    result = case(c):
        of 'A', 'X':
            ROCK
        of 'B', 'Y':
            PAPER
        of 'C', 'Z':
            SCISSORS
        else:
            raise newException(ValueError, "Invalid value")

func mapResult(c: char): Result =
    result = case (c):
        of 'X':
            LOSS
        of 'Y':
            DRAW
        of 'Z':
            WIN
        else:
            raise newException(ValueError, "Invalid value")

func getMineFromOppAndResult(opp: HandShape, r: Result): HandShape = 
    result = otherMatrix[ord(opp) - 1][ord(r) div 3]


func getScore(opp: HandShape, mine: HandShape): int = scoreMatrix[ord(opp) - 1][ord(mine) - 1]


func part1(input: string): int =
    var opp, mine: char
    for line in input.splitLines():
        discard scanf(line, "$c $c", opp, mine)
        result += getScore(opp.mapHandShape, mine.mapHandShape)

func part2(input: string): int =
    var opp, r: char
    for line in input.splitLines():
        discard scanf(line, "$c $c", opp, r)
        let oppHand = opp.mapHandShape
        let res = r.mapResult
        let mine = getMineFromOppAndResult(oppHand, res)
        result += getScore(oppHand, mine)
        

proc main() =
    echo part1(REAL_INPUT)
    echo part2(REAL_INPUT)

main()