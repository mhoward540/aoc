import aoc_util/gridutil.{type Coord, type GridS}
import gleam/bool
import gleam/dict
import gleam/io
import gleam/iterator
import gleam/list
import gleam/set.{type Set}

type Direction {
  Up
  Right
  Down
  Left
}

fn turn_90(d: Direction) {
  case d {
    Up -> Right
    Right -> Down
    Down -> Left
    Left -> Up
  }
}

fn move(c: Coord, d: Direction) {
  let #(y_diff, x_diff) = case d {
    Up -> #(-1, 0)
    Right -> #(0, 1)
    Down -> #(1, 0)
    Left -> #(0, -1)
  }

  #(c.0 + y_diff, c.1 + x_diff)
}

type Librarian {
  Librarian(location: Coord, direction: Direction)
}

fn parse_input(input: String) -> #(GridS, Librarian) {
  let grid =
    input
    |> gridutil.to_grid

  let start_coord =
    grid
    |> gridutil.iter_grid
    |> iterator.fold_until(#(-1, -1), fn(acc, entry) {
      let #(coord, v) = entry
      case v {
        "^" -> list.Stop(coord)
        _ -> list.Continue(coord)
      }
    })

  #(grid, Librarian(start_coord, Up))
}


// TODO this is probably faster than recursion - rewrite to use this?
fn map_covered_area(grid: GridS, l: Librarian) -> Set(Coord) {
  let visited_coords =
    iterator.unfold(l, fn(lib) {
      let next_coord = move(lib.location, lib.direction) |> io.debug
      let next_space = dict.get(grid.matrix, next_coord)

      case next_space {
        Ok("#") ->
          iterator.Next(
            lib.location,
            Librarian(lib.location, turn_90(lib.direction)),
          )
        Ok(_) ->
          iterator.Next(lib.location, Librarian(next_coord, lib.direction))
        _ -> iterator.Done
      }
    })

  visited_coords
  |> iterator.to_list
  |> set.from_list
}

fn visit(
  grid: GridS,
  lib: Librarian,
  visited: Set(Librarian),
) -> #(Set(Librarian), Bool) {
  use <- bool.guard(set.contains(visited, lib), #(visited, True))
  let visited = set.insert(visited, lib)
  let next_coord = move(lib.location, lib.direction)
  let next_space = dict.get(grid.matrix, next_coord)
  case next_space {
    Ok("#") ->
      visit(
        grid,
        Librarian(lib.location, turn_90(lib.direction)),
        visited,
      )
    Ok(_) ->
      visit(grid, Librarian(next_coord, lib.direction), visited)
    _, -> #(visited, False)
  }
}

fn causes_loop(grid: GridS, lib: Librarian) -> Bool {
  visit(grid, lib, set.new()).1
}

pub fn pt_1(input: String) {
  let #(grid, lib) =
    input
    |> parse_input

  let #(visited, _loops) =
    visit(grid, lib, set.new())

  visited
  |> set.map(fn(x) {x.location})
  |> set.size
}

pub fn pt_2(input: String) {
  let #(grid, lib) =
    input
    |> parse_input

  gridutil.iter_grid(grid)
  |> iterator.map(fn(entry) {
    let #(coord, space) = entry
    case space {
      "#" -> False
      _ -> {
        let g = dict.insert(grid.matrix, coord, "#")
        causes_loop(
          gridutil.Grid(matrix: g, max_y: grid.max_y, max_x: grid.max_x), 
          lib
        )
      }
    }
  })
  |> iterator.fold(0, fn(acc, looped) { acc + bool.to_int(looped) })
}
