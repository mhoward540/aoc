import aoc_util/gridutil.{type Coord, type GridS}
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

pub fn pt_1(input: String) {
  let #(grid, lib) =
    input
    |> parse_input

  let s =
    map_covered_area(grid, lib)
    |> set.size
  
  s + 1
}

pub fn pt_2(input: String) {
  todo as "part 2 not implemented"
}
