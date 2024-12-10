import aoc_util/gridutil.{type Coord, type Grid}
import gleam/bool
import gleam/dict
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/result
import gleam/set.{type Set}

type GridI =
  Grid(Int)

fn parse_input(input: String) -> #(GridI, List(Coord)) {
  let grid =
    input
    |> gridutil.to_grid_transform(fn(s) {
      let assert Ok(num) = int.parse(s)
      num
    })

  let trailheads =
    grid
    |> gridutil.iter_grid
    |> iterator.filter_map(fn(item) {
      let #(coord, value) = item
      case value == 0 {
        True -> Ok(coord)
        False -> Error(Nil)
      }
    })
    |> iterator.to_list

  #(grid, trailheads)
}

fn get_next_coords(
  curr_coord: Coord,
  curr_val: Int,
  grid: GridI,
  visited: Set(Coord),
) -> List(#(Coord, Int)) {
  [
    gridutil.add(curr_coord, #(1, 0)),
    gridutil.add(curr_coord, #(0, 1)),
    gridutil.add(curr_coord, #(-1, 0)),
    gridutil.add(curr_coord, #(0, -1)),
  ]
  |> list.filter(fn(coord) {
    gridutil.contains(grid, coord) && !set.contains(visited, coord)
  })
  |> list.map(fn(coord) {
    let assert Ok(next_val) = dict.get(grid.matrix, coord)
    #(coord, next_val)
  })
  |> list.filter(fn(item) {
    let #(_, next_val) = item
    next_val == curr_val + 1
  })
}

fn follow_trail(
  curr_coord: Coord,
  curr_val: Int,
  grid: GridI,
  visited: Set(Coord),
  curr_path: List(Coord),
  paths: Set(List(Coord)),
) -> Set(List(Coord)) {
  use <- bool.guard(curr_val == 9, {
    let curr_path = [curr_coord, ..curr_path]
    set.insert(paths, curr_path)
  })
  let next_coords = get_next_coords(curr_coord, curr_val, grid, visited)
  use <- bool.guard(list.is_empty(next_coords), set.new())
  let visited = set.insert(visited, curr_coord)
  let curr_path = [curr_coord, ..curr_path]

  next_coords
  |> list.fold(set.new(), fn(acc, entry) {
    let #(next_coord, next_val) = entry

    set.union(
      follow_trail(next_coord, next_val, grid, visited, curr_path, paths),
      acc,
    )
  })
}

pub fn pt_1(input: String) {
  let #(grid, trailheads) =
    input
    |> parse_input

  trailheads
  |> list.map(fn(th) {
    // Get the coords of all the exits we visited, count all the unique ones
    follow_trail(th, 0, grid, set.new(), [], set.new())
    |> set.to_list
    |> list.map(list.first)
    |> result.values
    |> set.from_list
    |> set.size
  })
  |> int.sum
}

pub fn pt_2(input: String) {
  let #(grid, trailheads) =
    input
    |> parse_input

  trailheads
  |> list.map(fn(th) { follow_trail(th, 0, grid, set.new(), [], set.new()) })
  |> list.map(set.size)
  |> int.sum
}
