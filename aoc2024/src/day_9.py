from collections import namedtuple
from bisect import bisect, bisect_right, insort, bisect_left
from itertools import groupby, chain
from typing import NamedTuple

class Fileblock(NamedTuple):
    start_index: int
    id: int
    run: int


class Space(NamedTuple):
    run: int
    start_index: int
    
    
# TODO ideally this would be done with bisect
def get_best_empty_space_index(l: list[Space], file: Fileblock) -> int | None:
    for i, space in enumerate(l):
        if space.run >= file.run and space.start_index < file.start_index:
            return i
    
    return None

def get_list_string(l: list[Fileblock | Space]) -> str:
    items = sorted(l, key=lambda x: x.start_index)

    out = []
    for item in items:
        if type(item) is Fileblock:
            out.extend([str(item.id)] * item.run)
            # out.extend(str(item.id) * item.run)
        else:
            out.extend(
                ["-1"] * item.run
            )

    return " ".join(out)

def print_list(l: list[Fileblock | Space]) -> None:
    print(get_list_string(l))

# TODO Ideally this would be done with insort
def insert_and_sort(s: list[Space], item: Space) -> None:
    s.append(item)
    s.sort(key=lambda sb: (sb.start_index))
    

def part2(in_str: str) -> int:
    chars = list(in_str)
    files = chars[::2]
    spaces = chars[1::2]

    if len(files) != len(spaces):
        spaces.append('0')

    fileblocks: list[Fileblock] = []
    space_blocks: list[Space] = []
    start_index = 0
    for i, (file, space) in enumerate(zip(files, spaces)):
        fb_size = int(file)
        fileblocks.append(
            Fileblock(
                start_index= start_index,
                id = i,
                run = fb_size
            )
        )

        start_index += fb_size

        space_size = int(space)
        space_blocks.append(
            Space(
                start_index = start_index,
                run=space_size
            )
        )

        start_index += space_size

    s_spaceblocks = space_blocks

    out: list[Fileblock] = []
    for file in reversed(fileblocks):
        
        insertion_space_i = get_best_empty_space_index(s_spaceblocks, file)

        if insertion_space_i is None:
            out.append(file)
            continue

        insertion_space = s_spaceblocks[insertion_space_i]

        if insertion_space.run == file.run:
            fb = Fileblock(
                start_index = insertion_space.start_index,
                id = file.id,
                run = file.run
            )
            out.append(fb)

            s_spaceblocks.pop(insertion_space_i)
            new_space = Space(
                start_index = file.start_index,
                run = file.run
            )

            insert_and_sort(s_spaceblocks, new_space)

        elif insertion_space.run > file.run:
            fb = Fileblock(
                start_index = insertion_space.start_index,
                id = file.id,
                run = file.run
            )

            out.append(fb)

            new_space = Space(
                start_index = fb.start_index + fb.run,
                run = insertion_space.run - fb.run
            )

            s_spaceblocks.pop(insertion_space_i)

            insert_and_sort(s_spaceblocks, new_space)
            
            replacement_space = Space(
                start_index = file.start_index,
                run = file.run
            )
            
            insert_and_sort(s_spaceblocks, replacement_space)
        else:
            out.append(file)

    result = 0
    for item in sorted(out, key=lambda x: x.start_index):
        if type(item) is Fileblock:
            # TODO dumb
            result += sum(item.id * index for index in range(item.start_index, item.start_index + item.run))
            
    return result


if __name__ == "__main__":
    in_str = ""
    with open("./input/2024/9.txt", "r") as f:
        in_str = f.read()

    print(part2(in_str))