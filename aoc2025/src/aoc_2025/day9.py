from collections import defaultdict
from enum import Enum
from typing import Optional, Set

Coord = tuple[int, int]


def parse_input(inp: str) -> list[Coord]:
    coords = []
    for line in inp.split("\n"):
        a, b = [int(c) for c in line.split(",")]
        coords.append((a, b))

    return coords


def area(c1: Coord, c2: Coord) -> int:
    h = abs(c1[1] - c2[1]) + 1
    w = abs(c1[0] - c2[0]) + 1

    return w * h


class Space(Enum):
    Red = "#"
    Green = "X"
    Empty = "."


def part1(red_tiles: list[Coord]):
    curr_max = -1
    for i, c1 in enumerate(red_tiles):
        for j, c2 in enumerate(red_tiles):
            if i == j:
                continue

            curr_max = max(area(c1, c2), curr_max)

    return curr_max


def draw_spaces(space_map: dict[Coord, Space], max_x: int, max_y: int):
    lines: list[str] = []
    for y in range(0, max_y + 1):
        line = []
        for x in range(0, max_x + 1):
            coord = (x, y)
            line.append(space_map[coord].value)

        line = "".join(line)
        lines.append(line)

    print("\n".join(lines))


def coords_for_area(c1: Coord, c2: Coord) -> Set[Coord]:
    min_x = min(c1[0], c2[0])
    max_x = max(c1[0], c2[0])

    min_y = min(c1[1], c2[1])
    max_y = max(c1[1], c2[1])

    return set((x, y) for x in range(min_x, max_x + 1) for y in range(min_y, max_y + 1))


def part2(coords: list[Coord]):
    space_map: dict[Coord, Space] = {}
    max_x = -1
    max_y = -1
    for coord in coords:
        max_x = max(max_x, coord[0])
        max_y = max(max_y, coord[1])
        space_map[coord] = Space.Red

    for x in range(max_x + 1):
        for y in range(max_y + 1):
            coord = (x, y)
            if not space_map.get(coord):
                space_map[coord] = Space.Empty

    # TODO chain iterables instead
    for p1, p2 in list(zip(coords, coords[1:])) + [(coords[0], coords[-1])]:
        x_min = min(p1[0], p2[0])
        x_max = max(p1[0], p2[0])
        y_min = min(p1[1], p2[1])
        y_max = max(p1[1], p2[1])

        for x in range(x_min, x_max + 1):
            for y in range(y_min, y_max + 1):
                coord = (x, y)
                if space_map.get(coord) != Space.Red:
                    space_map[coord] = Space.Green

    # so far we have all the red and green spaces on the boundaries correctly marked
    # now we have to fill the inner space of the shape
    draw_spaces(space_map, max_x, max_y)

    # y index mapped to a list of tuples of [x index, space]
    row_map: dict[int, list[tuple[int, Space]]] = defaultdict(list)

    for x in range(0, max_x + 1):
        for y in range(0, max_y + 1):
            coord = (x, y)
            space = space_map[coord]
            if space != Space.Empty:
                row_map[y].append((x, space))

    for y in range(0, max_y + 1):
        row = row_map[y]
        if not row:
            continue

        min_x = min(cell[0] for cell in row)
        max_x = max(cell[0] for cell in row)

        for x in range(min_x + 1, max_x):
            space_map[(x, y)] = Space.Green

    print("")
    draw_spaces(space_map, max_x, max_y)
    print("")


if __name__ == "__main__":
    s = ""
    with open("input/2025/9.txt") as f:
        s = f.read()

    inp = parse_input(s)
    print("Part 1:", part1(inp))
    print("Part 2:", part2(inp))
