from dataclasses import dataclass
from functools import lru_cache, reduce
from itertools import combinations
from typing import TypeVar


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
    assert n.bit_length() <= length
    out = []
    for _ in range(length):
        out.append(n & 1)
        n >>= 1
    return tuple(out)


def add_tuples(t1: tuple[int, ...], t2: tuple[int, ...]) -> tuple[int, ...]:
    assert len(t1) == len(t2)

    return tuple(n1 + n2 for n1, n2 in zip(t1, t2))


def sub_tuples(t1: tuple[int, ...], t2: tuple[int, ...]) -> tuple[int, ...]:
    assert len(t1) == len(t2)

    return tuple(n1 - n2 for n1, n2 in zip(t1, t2))


def parse_input(inp: str):
    entries = []
    for line in inp.split("\n"):
        thing = line.split(" ")
        diagram, state_len = build_diagram(thing[0])

        joltages = build_joltages(thing[-1])

        toggles = build_toggles(thing[1:-1])

        entries.append(Entry(diagram, state_len, toggles, joltages))

    return entries


T = TypeVar("T")


def all_combos(lst: list[T]):
    """
    Combinations of all possible lengths for given list
    """
    return (c for r in range(1, len(lst) + 1) for c in combinations(lst, r))


def min_presses(possible_press_masks: list[int], final_state: int):
    min_presses = float("inf")
    possible_presses: list[tuple[int, ...]] = []
    for combo in all_combos(possible_press_masks):
        res = reduce(lambda a, b: a ^ b, combo)
        if res != final_state:
            continue

        possible_presses.append(combo)
        if len(combo) < min_presses:
            min_presses = len(combo)

    return min_presses, possible_presses


def part1(entries: list[Entry]):
    l = [
        min_presses(entry.possible_press_masks, entry.final_state) for entry in entries
    ]
    return sum(presses for presses, _ in l)


# https://www.reddit.com/r/adventofcode/comments/1pk87hl/2025_day_10_part_2_bifurcate_your_way_to_victory/
def handle_entry(entry: Entry) -> int:
    @lru_cache(maxsize=None)
    def helper(desired_joltages: tuple[int, ...]) -> float:
        if all(j == 0 for j in desired_joltages):
            return 0.0

        parity = tuple(j % 2 for j in desired_joltages)
        parity_mask = set_bits([i for i, b in enumerate(parity) if b == 1])

        _, presses = min_presses(entry.possible_press_masks, parity_mask)

        if parity_mask == 0:
            presses = presses + [()]

        if not presses:
            return float("inf")

        best = float("inf")

        for press in presses:
            new_joltage = reduce(
                sub_tuples,
                (get_bits(p, len(desired_joltages)) for p in press),
                desired_joltages,
            )

            if any(j < 0 for j in new_joltage):
                continue

            halved, mods = zip(*[divmod(j, 2) for j in new_joltage])
            if any(mod == 1 for mod in mods):
                continue

            sub = helper(halved)
            if sub == float("inf"):
                continue

            parity_cost = len(press)
            total_cost = (2 * sub) + parity_cost
            if total_cost < best:
                best = total_cost

        return best

    res = helper(entry.joltages)
    return -1 if res == float("inf") else int(res)


def part2(entries: list[Entry]):
    return sum(handle_entry(entry) for entry in entries)


if __name__ == "__main__":
    s = ""
    with open("input/2025/10.txt") as f:
        s = f.read()

    inp = parse_input(s)
    print("Part 1:", part1(inp))
    print("Part 2:", part2(inp))
    # # 4653414735 too high
    # print("Part 2:", part2(inp))
