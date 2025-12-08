from itertools import combinations
from math import sqrt
from operator import ne

Coord3d = tuple[float, float, float]
Connection = tuple[Coord3d, Coord3d]


def dist(connection: Connection) -> float:
    c1, c2 = connection
    a = c1[0] - c2[0]
    b = c1[1] - c2[1]
    c = c1[2] - c2[2]

    return sqrt((a**2) + (b**2) + (c**2))


def part1(inp: str, iterations: int):
    coords = []
    for line in inp.split("\n"):
        x, y, z = line.split(",")
        coords.append(
            (
                float(x),
                float(y),
                float(z),
            )
        )

    connections: list[Connection] = [(a, b) for a, b in combinations(coords, 2)]
    connections.sort(key=dist)

    circuits: dict[int, set[Coord3d]] = dict()
    next_id = 0
    for c in connections[:iterations]:
        a, b = c
        containing = [k for k, v in circuits.items() if a in v or b in v]

        if len(containing) == 0:
            circuits[next_id] = {a, b}
            next_id += 1
        elif len(containing) == 1:
            id = containing[0]
            circuits[id] |= {a, b}
        else:
            new_circuit = set()
            for id in containing:
                new_circuit |= circuits[id]

            first_id = containing[0]
            circuits[first_id] = new_circuit
            for id in containing[1:]:
                del circuits[id]

    res = sorted(circuits.values(), key=len, reverse=True)[:3]
    acc = 1
    for circuit in res:
        acc *= len(circuit)

    return acc


if __name__ == "__main__":
    s = ""
    with open("input/2025/8.txt") as f:
        s = f.read()

    print(part1(s, 1000))
