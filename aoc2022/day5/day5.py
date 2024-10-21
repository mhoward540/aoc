import re
from collections import deque, namedtuple

StackMovement = namedtuple('StackMovement', ['amount', 'source', 'dest'])

_TEST_INPUT = """    [D]    
[N] [C]    
[Z] [M] [P]
 1   2   3 

move 1 from 2 to 1
move 3 from 1 to 3
move 2 from 2 to 1
move 1 from 1 to 2"""

with open("day5/real_input.txt", "r") as f:
    _REAL_INPUT = f.read()


def parse_input(instr: str) -> tuple[list[deque[str]], list[StackMovement]]:
    stack_def, movement_def = [s.splitlines(keepends=True) for s in instr.split("\n\n")]

    num_stacks = int(stack_def[-1].replace(" ", "")[-1])
    stacks = [deque() for _ in range(num_stacks)]

    # stack_regex = r"((\[[A-Z]\])|(   ))( ?)"

    for line in stack_def[:-1]:
        for i in range(num_stacks):
            # hardcoding the 4 offset here. Each char in the stack is either 3 spaces or [?], separated by 1 space
            curr_chunk = line[i * 4:(i + 1) * 4]

            if curr_chunk == "    " or curr_chunk == "   \n":
                continue

            curr_char = curr_chunk[1]

            stacks[i].append(curr_char)

    movement_regex = r"move (\d+) from (\d+) to (\d+)"

    movements = []
    for line in movement_def:
        m = re.match(movement_regex, line)
        [amount, source, dest] = [int(s) for s in m.groups()]
        movement = StackMovement(amount=amount, source=source - 1, dest=dest - 1)
        movements.append(movement)

    return stacks, movements


def part1(stacks: list[deque[str]], movements: list[StackMovement]) -> str:
    for movement in movements:
        [amount, source, dest] = movement
        for _ in range(amount):
            stacks[dest].appendleft(stacks[source].popleft())

    result = "".join(stack.popleft() for stack in stacks)
    return result


def part2(stacks: list[deque[str]], movements: list[StackMovement]) -> str:
    for movement in movements:
        [amount, source, dest] = movement
        to_add = []
        for _ in range(amount):
            to_add.append(stacks[source].popleft())

        for item in reversed(to_add):
            stacks[dest].appendleft(item)

    result = "".join(stack.popleft() for stack in stacks)
    return result


if __name__ == "__main__":
    print(part1(*parse_input(_REAL_INPUT)))
    print(part2(*parse_input(_REAL_INPUT)))
