from collections import deque
from dataclasses import dataclass
from functools import lru_cache, reduce
from itertools import combinations
from typing import Any, Deque


@dataclass
class Entry:
    final_state: int
    state_len: int
    possible_press_masks: list[int]
    joltages: tuple[int, ...]


def build_diagram(s: str):
    s = s[1:-1]

    return set_bits([i for i, c in enumerate(s) if c == "#"]), len(s)


def build_toggles(s: list[str]) -> list[int]:
    masks = []
    for toggle in s:
        toggle = toggle[1:-1]
        indices_l = [int(num) for num in toggle.split(",")]
        masks.append(set_bits(indices_l))

    return masks


def build_joltages(s: str) -> tuple[int, ...]:
    s = s[1:-1]
    l: list[int] = []
    for j in s.split(","):
        l.append(int(j))

    return tuple(l)


def set_bits(bit_indices: list[int]) -> int:
    """
    Set bits to 1 at the given indices, then return the number representing those bits being set
    """
    mask = 0

    for i in bit_indices:
        mask |= 1 << i

    return mask


# TODO is cache faster than loop?
# @lru_cache
def get_bits(n: int, length: int) -> tuple[int, ...]:
    out = []
    for _ in range(length):
        out.append(n & 1)
        n >>= 1
    return tuple(out[::-1])


def add_tuples(t1: tuple[int, ...], t2: tuple[int, ...]) -> tuple[int, ...]:
    assert len(t1) == len(t2)

    return tuple(n1 + n2 for n1, n2 in zip(t1, t2))


def parse_input(inp: str):
    entries = []
    for line in inp.split("\n"):
        thing = line.split(" ")
        diagram, state_len = build_diagram(thing[0])

        joltages = build_joltages(thing[-1])
        print(joltages)

        toggles = build_toggles(thing[1:-1])

        entries.append(Entry(diagram, state_len, toggles, joltages))

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


def handle_entry2(entry: Entry) -> int:
    zero = tuple([0 for _ in entry.joltages])
    # mask to check, curr_joltages, curr_xor, curr number of presses
    d: Deque[tuple[int, tuple[int, ...], int, int]] = deque(
        [(mask, zero, 0, 0) for mask in entry.possible_press_masks]
    )

    # bfs
    while d:
        t = d.popleft()
        print(t)
        mask, curr_jolt, xor, num_presses = t

        if curr_jolt == entry.joltages and xor == entry.final_state:
            print("FOUND FOUND FOUND")
            print("FOUND FOUND FOUND")
            print("FOUND FOUND FOUND")
            print("FOUND FOUND FOUND")
            print("")
            print("")

            return num_presses
        elif curr_jolt >= entry.joltages:
            continue
        else:
            bits = get_bits(mask, entry.state_len)
            new_jolt = add_tuples(bits, curr_jolt)
            new_xor = mask ^ xor

            deque.extend(
                d,
                (
                    (next_mask, new_jolt, new_xor, num_presses + 1)
                    for next_mask in entry.possible_press_masks
                    if next_mask != mask
                ),
            )

    return -1


def part2(entries: list[Entry]):
    l = [handle_entry2(entry) for entry in entries]
    print(l)
    return sum(l)


if __name__ == "__main__":
    s = ""
    with open("input/2025/10.txt") as f:
        s = f.read()

    inp = parse_input(s)
    print("Part 1:", part1(inp))
    print("Part 2:", part2(inp))
    # # 4653414735 too high
    # print("Part 2:", part2(inp))
