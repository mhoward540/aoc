def tilt_south(grid: list[list[str]]):
    for y in range(len(grid) - 2, -1, -1):
        for x in range(len(grid[0])):
            space = grid[y][x]
            if space != "O":
                continue

            i = y
            while i < len(grid) - 1 and grid[i + 1][x] == ".":
                i += 1

            # print("moving y,x", y, x, " to ", i, x)
            if i != y:
                grid[i][x] = "O"
                grid[y][x] = "."

            # print_grid(grid)
            # print("")


def tilt_west(grid: list[list[str]]):
    for x in range(1, len(grid[0])):
        for y in range(len(grid)):
            space = grid[y][x]
            if space != "O":
                continue

            i = x
            while i > 0 and grid[y][i - 1] == ".":
                i -= 1

            # print("moving y,x", y, x, " to ", y, i)
            if i != x:
                grid[y][i] = "O"
                grid[y][x] = "."

            # print_grid(grid)
            # print("")

def tilt_east(grid: list[list[str]]):
    for x in range(len(grid[0]) - 2, -1, -1):
        for y in range(len(grid)):
            space = grid[y][x]
            if space != "O":
                continue

            i = x
            while i < len(grid[0]) - 1 and grid[y][i + 1] == ".":
                i += 1

            # print("moving y,x", y, x, " to ", y, i)
            if i != x:
                grid[y][i] = "O"
                grid[y][x] = "."

            # print_grid(grid)
            # print("")


def tilt_north(grid: list[list[str]]):
    for y in range(1, len(grid)):
        for x in range(len(grid[0])):
            space = grid[y][x]
            if space != "O":
                continue

            i = y
            while i > 0 and grid[i - 1][x] == ".":
                i -= 1

            # print("moving y,x", y, x, " to ", i, x)
            if i != y:
                grid[i][x] = "O"
                grid[y][x] = "."

            # print_grid(grid)
            # print("")
            #



def score(grid: list[list[str]]) -> int:
    s = 0
    for i, row in enumerate(grid):
        s += sum([(1 if space == "O" else 0) for space in row]) * (len(grid) - i)

    return s


def print_grid(grid: list[list[str]]):
    for row in grid:
        print(" ".join(row))
    print("")

def part1(inp: str) -> int:
    grid = [list(line) for line in inp.split("\n")]
    # print_grid(grid)
    # print("")
    tilt_north(grid)
    # print_grid(grid)
    return score(grid)

def part2(inp: str) -> int:
    grid = [list(line) for line in inp.split("\n")]
    # print_grid(grid)
    # We could do clever caching or something here with tuples
    # but realistically the answer will converge after a certain number of iterations
    # I just guessed 1000 is good enough (and it was)
    for i in range(1000):
        # print(i + 1)
        tilt_north(grid)
        # print_grid(grid)
        tilt_west(grid)
        # print_grid(grid)
        tilt_south(grid)
        # print_grid(grid)
        tilt_east(grid)
        # print_grid(grid)
        # print("===================")

    return score(grid)

if __name__ == "__main__":
    inp = ""
    with open("14.txt", "r") as f:
        inp = f.read()

    print("part1")
    print(part1(inp))
    print("")
    print("")
    print("part2")
    print(part2(inp))
