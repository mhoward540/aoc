from itertools import combinations
from math import sqrt
from operator import ne

Coord3d = tuple[float, float, float]


def dist(c1: Coord3d, c2: Coord3d) -> float:
    a = c1[0] - c2[0]
    b = c1[1] - c2[1]
    c = c1[2] - c2[2]

    return sqrt((a**2) + (b**2) + (c**2))


def part1(inp: str):
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

    neighbor_map: dict[Coord3d, tuple[Coord3d, float]] = dict()
    distances: list[tuple[float, Coord3d, Coord3d]] = []
    for a, b in combinations(coords, 2):
        distance = dist(a, b)
        distances.append((distance, a, b))

    distances.sort()
    distances = distances[:1000]

    circuits: dict[int, set[Coord3d]] = dict()
    next_index = 0
    for d, a, b in distances:
        for k, v in circuits.items():
            print(k, v)
        print("")
        print("")
        print("")
        matching_circuits = [
            k for k, circuit in circuits.items() if a in circuit or b in circuit
        ]

        if len(matching_circuits) == 1:
            i = matching_circuits[0]
            circuits[i].add(a)
            circuits[i].add(b)
        elif len(matching_circuits) == 0:
            circuits[next_index] = set([a, b])
            next_index += 1
        else:
            new_circuit = set()
            for i in matching_circuits:
                new_circuit = new_circuit | circuits[i]

            first = matching_circuits[0]
            circuits[first] = new_circuit
            for i in matching_circuits[1:]:
                del circuits[i]

    itr = sorted(circuits.values(), key=len, reverse=True)
    print(itr[0])
    print(len(itr[0]))
    print(itr[1])
    print(len(itr[1]))
    print(itr[2])
    print(len(itr[2]))


if __name__ == "__main__":
    s = ""
    with open("input/2025/8.txt") as f:
        s = f.read()

    print(part1(s))
