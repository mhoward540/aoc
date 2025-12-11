from functools import lru_cache

PathMap = dict[str, list[str]]


def parse_input(s: str):
    d: PathMap = {}
    for line in s.split("\n"):
        start, nodes = line.split(": ")

        nodes = nodes.split(" ")

        d[start] = nodes

    return d


def part1(d: PathMap):
    return paths_from("you", "out", d)


def _paths_from(d: PathMap):
    @lru_cache
    def inner(node: str, end: str) -> int:
        if node == end:
            return 1

        return sum(inner(n, end) for n in d.get(node, []))

    return inner


def paths_from(node: str, end: str, d: PathMap):
    return _paths_from(d)(node, end)


def part2(d: PathMap):
    svr_to_dac = paths_from("svr", "dac", d)
    svr_to_fft = paths_from("svr", "fft", d)

    if svr_to_dac < svr_to_fft:
        return svr_to_dac * paths_from("dac", "fft", d) * paths_from("fft", "out", d)
    else:
        return svr_to_fft * paths_from("fft", "dac", d) * paths_from("dac", "out", d)


if __name__ == "__main__":
    s = ""
    with open("input/2025/11.txt") as f:
        s = f.read()

    inp = parse_input(s)
    print("Part 1:", part1(inp))
    print("Part 2:", part2(inp))
