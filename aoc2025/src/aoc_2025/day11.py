from collections import deque
from dataclasses import dataclass
from functools import lru_cache, reduce
from itertools import combinations
from typing import Any, Deque

PathMap = dict[str, list[str]]


def parse_input(s: str):
    d: PathMap = {}
    for line in s.split("\n"):
        start, nodes = line.split(": ")

        nodes = nodes.split(" ")

        d[start] = nodes

    return d


def path_from(
    d: PathMap, start: str, end: str, through: None | list[str]
) -> tuple[list[str], int]:
    path_count = 0
    paths = []

    to_visit = deque([start])

    while to_visit:
        node = to_visit.popleft()

        if node == end or d.get(node) is None:
            path_count += 1
            continue

        to_visit.extend(d[node])

    return paths, path_count


def part1(d: PathMap):
    return path_from(d, "you", "out", [])


if __name__ == "__main__":
    s = ""
    with open("input/2025/11.txt") as f:
        s = f.read()

    inp = parse_input(s)
    print("Part 1:", part1(inp))
    # print("Part 2:", part2(inp))
    # # 4653414735 too high
    # print("Part 2:", part2(inp))
