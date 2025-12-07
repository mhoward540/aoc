def part2(inp: str):
    yons: list[list[int]] = []
    for line in inp.split("\n"):
        yons.append([i for i, c in enumerate(line) if c == "^"])

    start = next(i for i, c in enumerate(inp) if c == "S")

    d: dict[int, int] = dict()
    d[start] = 1
    for line in yons:
        new_d = {k: v for k, v in d.items()}
        split_beams = set(new_d.keys()) & set(line)
        for beam in split_beams:
            del new_d[beam]
            new_d[beam - 1] = (new_d.get(beam - 1, 0)) + d[beam]
            new_d[beam + 1] = (new_d.get(beam + 1, 0)) + d[beam]
        d = new_d

    return sum(d.values())


if __name__ == "__main__":
    s = ""
    with open("input/2025/7.txt") as f:
        s = f.read()

    print(part2(s))
