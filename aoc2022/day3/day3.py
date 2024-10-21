from string import ascii_letters

_TEST_INPUT = """vJrwpWtwJgWrhcsFMMfFFhFp
jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
PmmdzqPrVvPwwTWBwg
wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
ttgJtRGJQctTZtZT
CrZsJsPPZsGzwwsLwLmpwMDw"""

_SCORE_TABLE = {letter: i + 1 for i, letter in enumerate(ascii_letters)}

with open("day3/real_input.txt", "r") as f:
    _REAL_INPUT = f.read()


def part1(instr: str) -> int:
    score = 0
    for line in instr.splitlines():
        s1 = set(line[:len(line) // 2])
        s2 = set(line[len(line) // 2:])
        shared_letter = s1.intersection(s2).pop()
        score += _SCORE_TABLE[shared_letter]

    return score


def part2(instr: str) -> int:
    score = 0
    lines = instr.splitlines()

    for i in range(0, len(lines), 3):
        line1 = set(lines[i])
        line2 = set(lines[i + 1])
        line3 = set(lines[i + 2])
        shared_letter = line1.intersection(line2).intersection(line3).pop()
        score += _SCORE_TABLE[shared_letter]

    return score


if __name__ == "__main__":
    print(part1(_REAL_INPUT))
    print(part2(_REAL_INPUT))
