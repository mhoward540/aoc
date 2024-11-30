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

// Should return all moves made by tracing the beam
fn trace_beam(start: Movement, d: Dict(Coord, Space)) -> VisitedCoords {
  #(
    [start],
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
        iterator.Next(element: next_moves, accumulator: #(
          next_moves,
          set.union(visited, set.from_list(moves)),
        ))
    }
  })
  // |> iterator.map(io.debug)
  // |> iterator.fold(set.new(), fn(a, b) { set.union(a, b) })
  |> iterator.to_list
  |> list.flatten
  |> list.prepend(start)
  |> set.from_list
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

type Grid =
  Dict(Coord, Space)

type Roots =
  Dict(
    Movement,
    #(
      Set(Movement),
      Int,
      // score - count of energized tiles
    ),
  )

// fn trace_beam_with_roots(start: Movement, grid: Grid, roots: Roots) -> #(Grid, Roots) {
//   [start]
//   |>
// }

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
    |> trace_beam(#(#(0, 0), Right), _)
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
  let d =
    input
    |> parse_input

  let #(height, width) =
    d
    |> dict.keys
    |> list.fold(#(0, 0), fn(a, b) { #(int.max(a.0, b.0), int.max(a.1, b.1)) })

  // smart thing to do would be keeping track of the root of the distinct paths, and merging/growing the path
  // when we encounter a move which has been made already. Then we can just compare the sizes of the distinct paths.
  // But this works quick enough, 1 or 2 seconds
  let start_moves =
    [
      list.range(0, width) |> list.map(fn(x) { #(#(0, x), Down) }),
      list.range(0, width) |> list.map(fn(x) { #(#(height, x), Up) }),
      list.range(0, height) |> list.map(fn(y) { #(#(y, 0), Right) }),
      list.range(0, height) |> list.map(fn(y) { #(#(y, width), Left) }),
    ]
    |> list.flatten
  // |> list.map(io.debug)

  let #(path, max) =
    start_moves
    |> list.map(fn(start) {
      let s =
        trace_beam(start, d)
        |> set.map(fn(x) { x.0 })
        |> set.to_list
        |> list.filter(fn(coord) {
          coord.0 >= 0 && coord.1 >= 0 && coord.0 <= height && coord.1 <= width
        })
        |> set.from_list

      #(s, set.size(s))
    })
    |> list.fold(#(set.new(), -1), fn(acc, entry) {
      let #(curr_path, curr_size) = entry
      let #(max_path, max_size) = acc

      case curr_size > max_size {
        True -> entry
        False -> acc
      }
    })

  // path
  // |> draw_grid(height, width, _)

  max
}
