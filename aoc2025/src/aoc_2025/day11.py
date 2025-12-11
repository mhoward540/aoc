from collections import deque
from dataclasses import dataclass
from functools import lru_cache, reduce
from itertools import combinations
from typing import Any, Deque


def parse_input(s: str):
    d: dict[str, list[str]] = {}
    for line in s.split("\n"):
        start, nodes = line.split(": ")

        nodes = nodes.split(" ")

        d[start] = nodes

    return d


def part1(d: dict[str, list[str]]):
    paths = 0

    to_visit = deque(["you"])

    while to_visit:
        node = to_visit.popleft()

        if node == "out":
            paths += 1
            continue

        to_visit.extend(d[node])

    return paths


if __name__ == "__main__":
    s = ""
    with open("input/2025/11.txt") as f:
        s = f.read()

    inp = parse_input(s)
    print("Part 1:", part1(inp))
    # print("Part 2:", part2(inp))
    # # 4653414735 too high
    # print("Part 2:", part2(inp))
