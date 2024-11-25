





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


def score(grid: list[list[str]]) -> int:
    s = 0
    for i, row in enumerate(grid):
        s += sum([(1 if space == "O" else 0) for space in row]) * (len(grid) - i)

    return s


def print_grid(grid: list[list[str]]):
    for row in grid:
        print(" ".join(row))

def part1(inp: str) -> int:
    grid = [list(line) for line in inp.split("\n")]
    # print_grid(grid)
    # print("")
    tilt_north(grid)
    # print_grid(grid)
    return score(grid)

if __name__ == "__main__":
    inp = ""
    with open("14.txt", "r") as f:
        inp = f.read()

    print("part1")
    print(part1(inp))
