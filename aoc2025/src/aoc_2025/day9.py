Corner = tuple[int, int]


def parse_input(inp: str) -> list[Corner]:
    corners = []
    for line in inp.split("\n"):
        a, b = [int(c) for c in line.split(",")]
        corners.append((a, b))

    return corners


def area(c1: Corner, c2: Corner) -> int:
    h = abs(c1[1] - c2[1]) + 1
    w = abs(c1[0] - c2[0]) + 1

    return w * h


def part1(corners: list[Corner]):
    curr_max = -1
    for i, c1 in enumerate(corners):
        for j, c2 in enumerate(corners):
            if i == j:
                continue

            curr_max = max(area(c1, c2), curr_max)

    return curr_max


def part2():
    pass


if __name__ == "__main__":
    s = ""
    with open("input/2025/9.txt") as f:
        s = f.read()

    inp = parse_input(s)
    print("Part 1:", part1(inp))
    # print("Part 2:", build_circuits(s, None))
