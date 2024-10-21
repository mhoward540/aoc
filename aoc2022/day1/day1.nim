import std/[strutils, sequtils, parseutils, sugar, heapqueue]

const TEST_INPUT = readFile("day1/test_input.txt")

const REAL_INPUT = readFile("day1/real_input.txt")

func part1(input: string): int =
    let elves = input.split("\n\n")
    result = low(int)

    for elf in elves:
        let lines = elf.split('\n')
        let currSum = lines.foldl(a + parseInt(b), 0)
        result = max(result, currSum)


func part2(input: string, nlargest: int): int =
    let elves = input.split("\n\n")
    var sums = initHeapQueue[int]()
    for elf in elves:
        let lines = elf.split('\n')
        # make sum negative such that the largest numbers come out of the heapqueue first
        # (since I'm lazy and don't want to create a custom type)
        let currSum = lines.foldl(a - parseInt(b), 0)
        sums.push(currSum)
    
    result = 0
    for i in 0..<nlargest:
        result -= sums.pop()


proc main() =
    echo part1(REAL_INPUT)
    echo part2(REAL_INPUT, 3)

main()