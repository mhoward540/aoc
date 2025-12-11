from collections import deque

PathMap = dict[str, list[str]]


def parse_input(s: str):
    d: PathMap = {}
    for line in s.split("\n"):
        start, nodes = line.split(": ")

        nodes = nodes.split(" ")

        d[start] = nodes

    return d


def path_from(
    d: PathMap, start: str, end: str, through: None | set[str]
) -> tuple[list[str], int]:
    path_count = 0
    paths = []

    to_visit = deque([(start, [])])

    while to_visit:
        node, curr_path = to_visit.popleft()

        if node == end or d.get(node) is None:
            if through and len(through) == len(through & set(curr_path)):
                path_count += 1
                paths.append([node] + curr_path)

            continue

        to_visit.extend((n, [node] + curr_path) for n in d[node])

    return paths, path_count


def part1(d: PathMap):
    return path_from(d, "you", "out", set())


def part2(d: PathMap):
    return path_from(d, "svr", "out", {"fft", "dac"})


if __name__ == "__main__":
    s = ""
    with open("input/2025/11.txt") as f:
        s = f.read()

    inp = parse_input(s)
    # print("Part 1:", part1(inp))
    print("Part 2:", part2(inp))
    # # 4653414735 too high
    # print("Part 2:", part2(inp))
