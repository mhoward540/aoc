def parse_presents(prezes: list[str]):
    out: list[int] = []
    for prez in prezes:
        area = 0
        for c in prez:
            area += 1 if c == "#" else 0

        out.append(area)

    return out


Tree = tuple[int, int, list[int]]


def parse_trees(trees: str):
    out: list[Tree] = []
    for tree in trees.split("\n"):
        dims, regions = tree.split(": ")
        width, height = [int(dim) for dim in dims.split("x")]
        regions = [int(region) for region in regions.split(" ")]
        out.append((width, height, regions))

    return out


def parse_input(inp: str) -> tuple[list[int], list[Tree]]:
    sections = inp.split("\n\n")
    presents_sect = sections[:-1]
    trees_sect = sections[-1]
    prezes = parse_presents(presents_sect)
    trees = parse_trees(trees_sect)
    return prezes, trees


def part1(prezes: list[int], trees: list[Tree]):
    out = 0
    for w, h, regions in trees:
        fits = w * h >= sum(region * prez for region, prez in zip(regions, prezes))
        out += int(fits)

    return out


if __name__ == "__main__":
    s = ""
    with open("input/2025/12.txt") as f:
        s = f.read()

    inp = parse_input(s)
    print("Part 1:", part1(*inp))
    # print("Part 2:", part2(inp))
