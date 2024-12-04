import gleam/dict.{type Dict}
import gleam/iterator
import gleam/list
import gleam/string
import aoc_util/gridutil.{type GridS, type Coord}

fn parse_input(input: String) -> GridS {
  input
  |> gridutil.to_grid
}

// start from top left and go diagonally down-right
fn get_diag_right(grid: GridS, start_y: Int, start_x: Int) -> String {
  iterator.unfold(#(start_y, start_x), fn(next_coord) {
    let #(next_y, next_x) = next_coord
    case next_y > grid.max_y, next_x > grid.max_x {
      False, False -> iterator.Next(next_coord, #(next_y + 1, next_x + 1))
      _, _ -> iterator.Done
    }
  })
  |> iterator.to_list
  |> list.map(fn(coord) {
    let assert Ok(c) = dict.get(grid.matrix, coord)
    c
  })
  |> string.join("")
}

// start from top right and go diagonally down-left
fn get_diag_left(grid: GridS, start_y: Int, start_x: Int) -> String {
  iterator.unfold(#(start_y, start_x), fn(next_coord) {
    let #(next_y, next_x) = next_coord
    case next_y > grid.max_y, next_x < 0 {
      False, False -> iterator.Next(next_coord, #(next_y + 1, next_x - 1))
      _, _ -> iterator.Done
    }
  })
  |> iterator.to_list
  |> list.map(fn(coord) {
    let assert Ok(c) = dict.get(grid.matrix, coord)
    c
  })
  |> string.join("")
}

// This assumes a square grid
fn get_diags_right(grid: GridS) -> List(String) {
  list.range(0, grid.max_y)
  |> list.map(fn(y) {
    case y == 0 {
      True -> [get_diag_right(grid, 0, 0)]
      False -> [get_diag_right(grid, 0, y), get_diag_right(grid, y, 0)]
    }
  })
  |> list.flatten
}

// This assumes a square grid
fn get_diags_left(grid: GridS) -> List(String) {
  list.range(0, grid.max_y)
  |> list.map(fn(i) {
    case i == 0 {
      True -> [get_diag_left(grid, 0, grid.max_x)]
      False -> {
        [
          get_diag_left(grid, i, grid.max_x),
          get_diag_left(grid, 0, grid.max_y - i),
        ]
      }
    }
  })
  |> list.flatten
}

fn get_sublines(line: String) -> List(String) {
  iterator.unfold(line, fn(s) {
    case string.pop_grapheme(s) {
      Ok(#(_, rest)) -> iterator.Next(s, rest)
      Error(_) -> iterator.Done
    }
  })
  |> iterator.to_list
}

fn solve_crossword(grid: GridS, words: List(String)) -> Int {
  let words =
    words
    |> list.map(fn(word) { [word, string.reverse(word)] })
    |> list.flatten

  // Get the full lines of the crossword
  // The entirety of each row, column, and diagonal
  let rows = gridutil.get_rows_joined(grid)
  let cols = gridutil.get_cols_joined(grid)
  let diag_right = get_diags_right(grid)
  let diag_left = get_diags_left(grid)

  // so if a row is "abcd" then the sublines are ["abcd", "bcd"]
  // we can check if any of these lines start with any of the words we care about
  // to know how many matches there are total
  let lines =
    [rows, cols, diag_right, diag_left]
    |> list.flatten
    |> list.map(get_sublines)
    |> list.flatten

  lines
  |> list.map(fn(line) {
    words
    |> list.map(fn(word) { string.starts_with(line, word) })
  })
  |> list.flatten
  |> list.count(fn(x) { x })
}

type MasCoords {
  MasCoords(tl: Coord, tr: Coord, mid: Coord, bl: Coord, br: Coord)
}

fn is_valid_entry(grid: GridS, m: MasCoords) -> Bool {
  let is_invalid =
    [m.tl, m.tr, m.mid, m.bl, m.br]
    |> list.map(fn(coord) {
      let #(y, x) = coord
      y < 0 || x < 0 || y >= grid.max_y + 1 || x >= grid.max_x + 1
    })
    |> list.any(fn(x) { x })

  !is_invalid
}

// Get the x-shape for a coord centered at c
fn get_mas_coords_for_entry(c: Coord) -> MasCoords {
  let #(y, x) = c
  MasCoords(
    tl: #(y - 1, x - 1),
    tr: #(y - 1, x + 1),
    mid: c,
    bl: #(y + 1, x - 1),
    br: #(y + 1, x + 1),
  )
}

// Valid X's of MAS:
// S M
//  A
// S M

// M M
//  A
// S S

// M S
//  A
// M S

// S S
//  A
// M M
fn is_a_mas_x(me: MasCoords, grid: GridS) -> Bool {
  let assert Ok(tl) = dict.get(grid.matrix, me.tl)
  let assert Ok(tr) = dict.get(grid.matrix, me.tr)
  let assert Ok(mid) = dict.get(grid.matrix, me.mid)
  let assert Ok(bl) = dict.get(grid.matrix, me.bl)
  let assert Ok(br) = dict.get(grid.matrix, me.br)
  case tl, tr, mid, bl, br {
    "S", "M", "A", "S", "M" -> True
    "M", "M", "A", "S", "S" -> True
    "M", "S", "A", "M", "S" -> True
    "S", "S", "A", "M", "M" -> True
    _, _, _, _, _ -> False
  }
}

fn get_mas_coords(grid: GridS) -> List(MasCoords) {
  list.range(0, grid.max_y)
  |> list.map(fn(y) {
    list.range(0, grid.max_x)
    |> list.map(fn(x) { get_mas_coords_for_entry(#(y, x)) })
  })
  |> list.flatten
  // ensure the entry is within the boundaries of the grid
  |> list.filter(is_valid_entry(grid, _))
}

fn find_mas(grid: GridS) -> Int {
  get_mas_coords(grid)
  |> list.filter(is_a_mas_x(_, grid))
  |> list.length
}

pub fn pt_1(input: String) {
  input
  |> parse_input
  |> solve_crossword(["XMAS"])
}

pub fn pt_2(input: String) {
  input
  |> parse_input
  |> find_mas
}
