import std/[strutils, parseutils]

type MyTree = object
    visibleFromRight: bool
    visibleFromLeft: bool
    visibleFromTop: bool
    visibleFromBottom: bool
    treeSize: uint8


type MyTreeRef = ref MyTree

const TEST_INPUT = readFile("day8/test_input.txt")

const REAL_INPUT = readFile("day8/real_input.txt")


proc parseInput(instr: string): seq[seq[MyTreeRef]] =
    result = newSeq[seq[MyTreeRef]]()
    for line in instr.splitLines:
        var currRow = newSeq[MyTreeRef]()
        for c in line:
            var treeSize: uint
            discard parseUint($c, treeSize)
            var newTree = new MyTreeRef
            newTree.treeSize = uint8(treeSize)
            currRow.add(newTree)
        
        result.add(currRow)

    for y in 0 ..< len(result):
        for x in 0 ..< len(result[0]):
            var currTree = result[y][x]
            currTree.visibleFromRight = x == len(result[0]) - 1
            currTree.visibleFromLeft = x == 0
            currTree.visibleFromTop = y == 0
            currTree.visibleFromBottom = y == len(result) - 1

    
    # for row in result:
    #     let outStr = row.foldl(a & ( $(b.treeSize) & ","), "")
    #     echo outStr


proc part1(trees: var seq[seq[MyTreeRef]]): uint =
    for y in 0 ..< trees.len:
        var directionMax = trees[y][trees[0].len - 1].treeSize
        for x in countdown(trees[0].len - 2, 0):
            let rightTree = trees[y][x]
            rightTree.visibleFromRight = rightTree.treeSize > directionMax
            if rightTree.treeSize > directionMax:
                directionMax = rightTree.treeSize
    
    for y in 0 ..< trees.len:
        var directionMax = trees[y][0].treeSize
        for x in 1 ..< trees[0].len:
            let leftTree = trees[y][x]
            leftTree.visibleFromLeft = leftTree.treeSize > directionMax
            if leftTree.treeSize > directionMax:
                directionMax = leftTree.treeSize
    
    for x in 0 ..< trees[0].len:
        var directionMax = trees[trees.len - 1][x].treeSize
        for y in countdown(trees.len - 2, 0):
            let bottomTree = trees[y][x]
            bottomTree.visibleFromBottom = bottomTree.treeSize > directionMax
            if bottomTree.treeSize > directionMax:
                directionMax = bottomTree.treeSize
    
    for x in 0 ..< trees[0].len:
        var directionMax = trees[0][x].treeSize
        for y in 1 ..< trees.len:
            let topTree = trees[y][x]
            topTree.visibleFromTop = topTree.treeSize > directionMax
            if topTree.treeSize > directionMax:
                directionMax = topTree.treeSize

    for y in 0 ..< trees.len:
        # var rowStr = ""
        for x in 0 ..< trees[0].len:
            let tree = trees[y][x]
            let isVisible = tree.visibleFromBottom or tree.visibleFromLeft or tree.visibleFromRight or tree.visibleFromTop
            if isVisible:
                result += 1
                # rowStr = rowStr & $isVisible & " ,"
            # else: 
                # rowStr = rowStr & ($isVisible & ",")
        
        # echo rowStr


proc part2(trees: var seq[seq[MyTreeRef]]): uint =
    #super suboptimal, seems like this could be solved with DP but I'm lazy
    result = 0
    for y in 0 ..< trees.len:
        for x in 0 ..< trees[0].len:
            #echo ""
            #echo "checking coords: y=" & $y  & ",x=" & $x
            if x == 0 or x == trees[0].len - 1 or y == 0 or y == trees.len - 1:
                #echo "coord is on the edge and will have a score of 0, skipping"
                continue

            # check all directions
            var currScore = 1'u
            var directionScore = 1'u
            var i = x - 1
            let currTreeSize = trees[y][x].treeSize

            while i > 0 and trees[y][i].treeSize < currTreeSize:
                directionScore += 1
                i -= 1
            
            #echo "direction score left: " & $directionScore
            currScore *= directionScore
            directionScore = 1
            i = x + 1

            while i < trees[0].len - 1 and trees[y][i].treeSize < currTreeSize:
                directionScore += 1
                i += 1
            
            #echo "direction score right: " & $directionScore
            currScore *= directionScore
            directionScore = 1
            var j = y - 1

            while j > 0 and trees[j][x].treeSize < currTreeSize:
                directionScore += 1
                j -= 1
            
            #echo "direction score up: " & $directionScore
            currScore *= directionScore
            directionScore = 1
            j = y + 1

            while j < trees.len - 1 and trees[j][x].treeSize < currTreeSize:
                directionScore += 1
                j += 1
            
            #echo "direction score down: " & $directionScore
            currScore *= directionScore
            #echo "final score: " & $currScore

            result = max(result, currScore)

            


proc main() =
    var inp = parseInput(REAL_INPUT)
    # echo part1(inp)
    echo part2(inp)

main()