import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/set.{type Set}
import gleam/string

// y, x
type Coord =
  #(Int, Int)

pub type Space {
  EmptySpace
  // "."
  ForwardMirror
  // "/"
  BackwardMirror
  // "\"
  VertSplit
  // "-"
  HorizSplit
  // "|"
}

pub type Direction {
  Up
  Down
  Left
  Right
}

fn parse_space(space_str: String) -> Space {
  case space_str {
    "." -> EmptySpace
    "/" -> ForwardMirror
    "\\" -> BackwardMirror
    "|" -> VertSplit
    "-" -> HorizSplit
    _ -> panic as "Unknown space character found"
  }
}

fn parse_line(line: String, line_number: Int) -> List(#(Coord, Space)) {
  line
  |> string.split("")
  |> list.index_map(fn(char, i) { #(#(line_number, i), parse_space(char)) })
}

fn parse_input(input: String) -> Dict(Coord, Space) {
  input
  |> string.split("\n")
  |> list.index_map(parse_line)
  |> list.flatten
  |> dict.from_list
}

pub type Movement =
  #(Coord, Direction)

fn calc_next_movements(move: Movement, curr_space: Space) -> List(Movement) {
  let #(coords, direction) = move

  let coord_changes = case curr_space, direction {
    EmptySpace, Right
    | HorizSplit, Right
    | ForwardMirror, Up
    | BackwardMirror, Down
    -> [#(#(0, 1), Right)]
    EmptySpace, Left
    | HorizSplit, Left
    | ForwardMirror, Down
    | BackwardMirror, Up
    -> [#(#(0, -1), Left)]
    EmptySpace, Down
    | VertSplit, Down
    | ForwardMirror, Left
    | BackwardMirror, Right
    -> [#(#(1, 0), Down)]
    EmptySpace, Up | VertSplit, Up | ForwardMirror, Right | BackwardMirror, Left
    -> [#(#(-1, 0), Up)]

    HorizSplit, Up | HorizSplit, Down -> [#(#(0, 1), Right), #(#(0, -1), Left)]
    VertSplit, Left | VertSplit, Right -> [#(#(1, 0), Down), #(#(-1, 0), Up)]
  }

  coord_changes
  |> list.map(fn(movement_diff) {
    let #(c, dr) = movement_diff

    #(#(c.0 + coords.0, c.1 + coords.1), dr)
  })
}

pub type MoveToVisit =
  List(Movement)

pub type VisitedCoords =
  Set(Movement)

fn trace_beam(
  d: Dict(Coord, Space),
  move: Movement,
  visited: VisitedCoords,
) -> #(VisitedCoords, MoveToVisit) {
  // io.debug(move)

  let #(coords, _direction) = move
  let maybe_space = dict.get(d, coords)
  let have_visited = set.contains(visited, move)

  case have_visited, maybe_space {
    _, Error(_) | True, _ -> #(visited, [])
    False, Ok(space) -> {
      calc_next_movements(move, space)
      |> list.map(trace_beam(d, _, set.insert(visited, move)))
      |> list.fold(#(set.new(), []), fn(entry, acc) {
        let #(acc_vis, acc_moves) = acc
        let #(entry_vis, entry_moves) = entry

        #(set.union(acc_vis, entry_vis), list.concat([entry_moves, acc_moves]))
      })
    }
  }
}

fn trace_beam2(d: Dict(Coord, Space)) -> VisitedCoords {
  #(
    [#(#(0, 0), Right)],
    // next moves
    set.new(),
    // visited
  )
  |> iterator.unfold(fn(entry) {
    let #(moves, visited) = entry

    let next_moves =
      moves
      |> list.filter_map(fn(move) {
        let #(coords, _direction) = move
        let maybe_space = dict.get(d, coords)
        let have_visited = set.contains(visited, move)

        case have_visited, maybe_space {
          _, Error(_) | True, _ -> Error(Nil)
          False, Ok(space) -> Ok(calc_next_movements(move, space))
        }
      })
      |> list.flatten

    case list.is_empty(next_moves) {
      True -> iterator.Done
      False ->
        iterator.Next(element: visited, accumulator: #(
          next_moves,
          set.union(visited, set.from_list(moves)),
        ))
    }
  })
  // |> iterator.map(io.debug)
  |> iterator.fold(set.new(), fn(a, b) { set.union(a, b) })
}

fn draw_grid(height: Int, width: Int, visited: Set(Coord)) -> Set(Coord) {
  height
  |> list.range(0, _)
  |> list.map(fn(y) {
    let s =
      width
      |> list.range(0, _)
      |> list.map(fn(x) {
        case set.contains(visited, #(y, x)) {
          False -> "."
          True -> "#"
        }
      })
      |> string.join("")
      |> io.debug
  })

  visited
}

pub fn pt_1(input: String) {
  let d =
    input
    |> parse_input

  let #(height, width) =
    d
    |> dict.keys
    |> list.fold(#(0, 0), fn(a, b) { #(int.max(a.0, b.0), int.max(a.1, b.1)) })
  // |> io.debug

  let s =
    d
    |> trace_beam2
    |> set.map(fn(x) { x.0 })

  s
  |> set.to_list
  |> list.filter(fn(coord) {
    coord.0 >= 0 && coord.1 >= 0 && coord.0 <= height && coord.1 <= width
  })
  // |> list.map(io.debug)
  |> set.from_list
  // |> draw_grid(height, width, _)
  |> set.size
}

pub fn pt_2(input: String) {
  todo as "part 2 not implemented"
}
