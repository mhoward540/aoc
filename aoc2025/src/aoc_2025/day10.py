from dataclasses import dataclass
from functools import reduce
from itertools import combinations
from typing import Any


@dataclass
class Entry:
    # state_len: int
    final_state: int
    possible_press_masks: list[int]


def build_diagram(s: str) -> int:
    s = s[1:-1]

    return set_bits([i for i, c in enumerate(s) if c == "#"])


def build_toggles(s: list[str]) -> list[int]:
    masks = []
    for toggle in s:
        toggle = toggle[1:-1]
        indices_l = [int(num) for num in toggle.split(",")]
        masks.append(set_bits(indices_l))

    return masks


def set_bits(bit_indices: list[int]) -> int:
    mask = 0

    for i in bit_indices:
        mask |= 1 << i

    return mask


def parse_input(inp: str):
    entries = []
    for line in inp.split("\n"):
        thing = line.split(" ")
        diagram = build_diagram(thing[0])

        joltages = thing[-1]

        toggles = build_toggles(thing[1:-1])

        entries.append(Entry(diagram, toggles))

    return entries


def all_combos(lst: list[Any]) -> list[list[Any]]:
    all_combinations = []
    for r in range(1, len(lst) + 1):
        all_combinations.extend(combinations(lst, r))

    return all_combinations


def handle_entry(entry: Entry):
    min_presses = 9999999999999
    for combo in all_combos(entry.possible_press_masks):
        res = reduce(lambda a, b: a ^ b, combo)
        if res == entry.final_state:
            min_presses = min(min_presses, len(combo))

    return min_presses


# 10000000000504 too high
def part1(entries: list[Entry]):
    l = [handle_entry(entry) for entry in entries]
    print(l)
    return sum(l)


if __name__ == "__main__":
    s = ""
    with open("input/2025/10.txt") as f:
        s = f.read()

    inp = parse_input(s)
    print("Part 1:", part1(inp))
    # # 4653414735 too high
    # print("Part 2:", part2(inp))
