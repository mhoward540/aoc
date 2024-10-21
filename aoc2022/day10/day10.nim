import std/[strscans, strutils, options, sequtils]


const TEST_INPUT1 = readFile("day10/test_input1.txt")
const TEST_INPUT2 = readFile("day10/test_input2.txt")
const REAL_INPUT = readFile("day10/real_input.txt")


proc part1(instructions: string, debug: bool): int =
    proc myEcho(s: string) = 
        if debug:
            echo s

    var x = 1
    var i = 1
    let interestingCycles = [20, 60, 100, 140, 180, 220]
    for line in instructions.splitLines():
        let (command, cycles, value) = 
            if line.startsWith("noop"):
                ("noop", 1, 0)
            else:
                ("addx", 2, scanTuple(line, "addx $i")[1])
        
        for j in 0 ..< cycles:
            myEcho "begin cycle " & $i
            myEcho "x is " & $x
            
            myEcho "during cycle " & $i
            myEcho "x is " & $x

            if i in interestingCycles:
                result += (x * i)

            if command == "addx" and j == cycles - 1:
                x += value

            myEcho "end cycle " & $i
            myEcho "x is " & $x
            myEcho ""

            i += 1


proc part2(instructions: string, debug: bool): string =
    proc myEcho(s: string) = 
        if debug:
            echo s

    var x = 1
    var i = 0

    var displayLine = newSeq[char](40)
    for line in instructions.splitLines():
        let (command, cycles, value) = 
            if line.startsWith("noop"):
                ("noop", 1, 0)
            else:
                ("addx", 2, scanTuple(line, "addx $i")[1])
        
        for j in 0 ..< cycles:
            let cycle = i + 1
            myEcho "Start cycle " & $cycle 
            myEcho "x is " & $x
            
            myEcho "During cycle " & $cycle
            myEcho "x is " & $x

            displayLine[i] = if x in [i - 1, i, i + 1]: '#' else: '.'

            if command == "addx" and j == cycles - 1:
                x += value

            myEcho "end cycle " & $cycle
            myEcho "x is " & $x
            myEcho ""

            i += 1
            if i == 40:
                result &= (displayLine.join() & "\n")
                displayLine = newSeq[char](40)
                i = 0


proc main() =
    echo part1(REAL_INPUT, false)
    echo part2(REAL_INPUT, false)

main()