from collections import defaultdict
from enum import Enum
from itertools import combinations
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


# Since there can be rectangle of length or width 1, this might return just 2 corners instead of 4
def all_corners(c1: Coord, c2: Coord) -> Set[Coord]:
    min_x = min(c1[0], c2[0])
    max_x = max(c1[0], c2[0])

    min_y = min(c1[1], c2[1])
    max_y = max(c1[1], c2[1])

    return {
        (min_x, min_y),
        (min_x, max_y),
        (max_x, min_y),
        (max_x, max_y),
    }


def minmax(gen):
    iterator = iter(gen)

    try:
        first = next(iterator)
    except StopIteration:
        return None, None  # Empty generator

    min_val = max_val = first

    for value in iterator:
        if value < min_val:
            min_val = value
        elif value > max_val:
            max_val = value

    return min_val, max_val


def part3(coords: list[Coord]):
    print("0")
    space_map: dict[Coord, Space] = {}
    # y index mapped to a list of tuples of [x index, space]
    row_map: dict[int, list[tuple[int, Space]]] = defaultdict(list)
    max_x = -1
    max_y = -1
    for coord in coords:
        x, y = coord
        max_x = max(max_x, x)
        max_y = max(max_y, y)
        space_map[coord] = Space.Red
        row_map[y].append((x, Space.Red))

    # TODO chain iterables instead
    print("1")
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
                    row_map[y].append((x, Space.Green))

    # so far we have all the red and green spaces on the boundaries correctly marked
    # now we have to fill the inner space of the shape

    # draw_spaces(space_map, max_x, max_y)
    print("2")

    # TODO this is slow
    # we can check that all 4 corners are in the shaded area
    # if so then the whole area is in the shaded area

    # print("3")
    # draw_spaces(space_map, max_x, max_y)

    for y in row_map.keys():
        row_map[y].sort()

    print("4")

    max_area = -1
    for c1, c2 in combinations(coords, 2):
        corners = all_corners(c1, c2)
        all_in_bounds = True
        for corner in corners:
            curr_row = row_map[corner[1]]
            low_bound, high_bound = curr_row[0][0], curr_row[-1][0]
            all_in_bounds = all_in_bounds and (
                corner[0] >= low_bound and corner[0] <= high_bound
            )

        if not all_in_bounds:
            continue

        print(corners)
        max_area = max(max_area, area(c1, c2))

    print("5")

    return max_area


def has_inclusions(
    coord_pairs: list[tuple[Coord, Coord]], p1: Coord, p2: Coord
) -> bool:
    min_x = min(p1[0], p2[0])
    min_y = min(p1[1], p2[1])
    max_x = max(p1[0], p2[0])
    max_y = max(p1[1], p2[1])

    for a, b in coord_pairs:
        # vertical segment
        if a[0] == b[0]:
            x = a[0]
            from_y, to_y = (a[1], b[1]) if a[1] <= b[1] else (b[1], a[1])
            if (x > min_x and x < max_x) and (from_y < max_y and to_y > min_y):
                return True
        else:
            # horizontal segment
            y = a[1]
            from_x, to_x = (a[0], b[0]) if a[0] <= b[0] else (b[0], a[0])
            if (y > min_y and y < max_y) and (from_x < max_x and to_x > min_x):
                return True

    return False


def part2(coords: list[Coord]):
    coord_pairs_help = [coords[-1]] + coords
    coord_pairs = list(zip(coord_pairs_help, coord_pairs_help[1:]))

    coords_with_area = sorted(
        ((c1, c2, area(c1, c2)) for c1, c2 in combinations(coords, 2)),
        key=lambda t: t[2],
        reverse=True,
    )

    return next(
        (
            area
            for x, y, area in coords_with_area
            if not has_inclusions(coord_pairs, x, y)
        ),
        -1,
    )


if __name__ == "__main__":
    s = ""
    with open("input/2025/9.txt") as f:
        s = f.read()

    inp = parse_input(s)
    print("Part 1:", part1(inp))
    # 4653414735 too high
    print("Part 2:", part2(inp))
