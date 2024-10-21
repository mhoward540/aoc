import std/[strutils, parseutils, strscans, options, tables, deques]

type MyFile = object
    name: string
    size: BiggestUInt

type MyFileRef = ref MyFile

type MyDir = object
    name: string
    files: seq[MyFileRef]
    childDirs: Table[string, ref MyDir]
    parentDir: Option[ref MyDir]
    size: BiggestUInt

type MyDirRef = ref MyDir

const TEST_INPUT = readFile("day7/real_input.txt")

const REAL_INPUT = readFile("day7/real_input.txt")


proc buildDirStructure(input: string): MyDirRef =
    let lines = input.splitLines()
    
    var i = 0
    let rootDir = new MyDirRef
    rootDir.name = "/"
    rootDir.files = @[]
    rootDir.parentDir = none(ref MyDir)

    var currDir = rootDir

    while i < len(lines):
        let line = lines[i]
        var (_, command) = scanTuple(line, "$$ $+")
        
        if command.startsWith("ls"):
            i += 1
            
            while i < len(lines) and not lines[i].startsWith("$ "):
                var contentLine = lines[i]
                let parts = contentLine.split(" ")
                if parts[0] == "dir":
                    let newDir = new MyDirRef
                    newDir.name = parts[1]
                    newDir.parentDir = some(currDir)
                    currDir.childDirs[parts[1]] = newDir
                else:
                    var fileSize: BiggestUInt
                    discard parseBiggestUInt(parts[0], fileSize, 0)
                    let fileName = parts[1]
                    let newFile = new MyFileRef
                    newFile.name = fileName
                    newFile.size = fileSize
                    currDir.files.add(newFile)
                i += 1

        elif command.startsWith("cd"):
            var (_, dirName) = scanTuple(command, "cd $+")
            if dirName == "..":
                currDir = currDir.parentDir.get()
            elif dirName == "/":
                currDir = rootDir
            else:
                currDir = currDir.childDirs[dirName]

            i += 1
    
    return rootDir


proc calculateDirSizes(rootDir: MyDirRef) =
    # TODO doing this the suboptimal way first and will be visiting some folders multiple times
    let firstEntry = (rootDir, newSeq[MyDirRef]())
    var toVisit = [firstEntry].toDeque()
    while len(toVisit) > 0:
        let (currDir, toModify) = toVisit.popFirst()
        var currSum: BiggestUInt
        for file in currDir.files:
            currSum += file.size
        
        for dir in (toModify & @[currDir]):
            dir.size += currSum

        
        for (key, dir) in currDir.childDirs.pairs:
            toVisit.addFirst(
                (dir, toModify & currDir)
            )


proc parseInput(instr: string): MyDirRef =
    result = buildDirStructure(instr)
    calculateDirSizes(result)


proc part1(rootDir: MyDirRef): BiggestUInt =
    var newToVisit = [rootDir].toDeque()
    while len(newToVisit) > 0:
        let currDir = newToVisit.popFirst()

        if currDir.size <= 100000:
            result += currDir.size
        
        for (key, dir) in currDir.childDirs.pairs:
            newToVisit.addFirst(dir)


proc part2(rootDir: MyDirRef): BiggestUInt =
    var unusedSpace = 70000000 - rootDir.size
    var currMin = high(BiggestUInt)
    var currMinDir: MyDirRef

    var newToVisit = [rootDir].toDeque()
    while len(newToVisit) > 0:
        let currDir = newToVisit.popFirst()

        if currDir.size + unusedSpace >= 30000000 and currDir.size < currMin:
            currMin = currDir.size
            currMinDir = currDir
        
        for (key, dir) in currDir.childDirs.pairs:
            newToVisit.addFirst(dir)

    return currMin


proc main() =
    echo(part1(parseInput(REAL_INPUT)))
    echo(part2(parseInput(REAL_INPUT)))

main()