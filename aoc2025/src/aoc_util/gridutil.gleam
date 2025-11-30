import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/order.{type Order}
import gleam/string
import gleam/yielder.{type Yielder}

pub type Coord =
  #(Int, Int)

pub type Matrix(value) =
  Dict(Coord, value)

pub type Grid(value) {
  Grid(matrix: Matrix(value), max_y: Int, max_x: Int)
}

pub type Cardinal {
  Up
  Right
  Down
  Left
}

pub type GridS =
  Grid(String)

pub fn insert(grid: Grid(value), c: Coord, v: value) -> Grid(value) {
  let matrix =
    grid.matrix
    |> dict.insert(c, v)

  Grid(matrix, grid.max_y, grid.max_x)
}

pub fn to_grid_transform(
  input: String,
  transform: fn(String) -> value,
) -> Grid(value) {
  let matrix_l =
    input
    |> string.split("\n")
    |> list.index_map(fn(line, y) {
      line
      |> string.split("")
      |> list.index_map(fn(char, x) {
        let t = transform(char)
        #(#(y, x), t)
      })
    })
    |> list.flatten

  let assert Ok(#(#(height, width), _)) = list.last(matrix_l)
  let matrix = matrix_l |> dict.from_list
  Grid(matrix: matrix, max_y: height, max_x: width)
}

pub fn to_grid(input: String) -> Grid(String) {
  input
  |> to_grid_transform(fn(s) { s })
}

pub fn get_rows(grid: Grid(value)) -> List(List(value)) {
  list.range(0, grid.max_y)
  |> list.map(fn(y) {
    list.range(0, grid.max_x)
    |> list.map(fn(x) {
      let coord = #(y, x)
      let assert Ok(c) = dict.get(grid.matrix, coord)
      c
    })
  })
}

pub fn coord_compare(a: Coord, b: Coord) -> Order {
  case int.compare(a.0, b.0) {
    order.Eq -> int.compare(a.1, b.1)
    o -> o
  }
}

pub fn get_rows_joined(grid: GridS) -> List(String) {
  grid
  |> get_rows
  |> list.map(fn(row) { string.join(row, "") })
}

pub fn get_cols(grid: Grid(value)) -> List(List(value)) {
  list.range(0, grid.max_x)
  |> list.map(fn(x) {
    list.range(0, grid.max_y)
    |> list.map(fn(y) {
      let coord = #(y, x)
      let assert Ok(c) = dict.get(grid.matrix, coord)
      c
    })
  })
}

pub fn get_cols_joined(grid: GridS) -> List(String) {
  grid
  |> get_cols
  |> list.map(fn(col) { string.join(col, "") })
}

pub fn iter_grid(grid: Grid(value)) -> Yielder(#(Coord, value)) {
  yielder.range(0, grid.max_y)
  |> yielder.map(fn(y) {
    yielder.range(0, grid.max_x)
    |> yielder.map(fn(x) {
      let c = #(y, x)
      let assert Ok(v) = dict.get(grid.matrix, c)
      #(c, v)
    })
  })
  |> yielder.flatten
}

pub fn stringify_grid_transform(
  grid: Grid(value),
  transform: fn(value) -> String,
) -> String {
  yielder.range(0, grid.max_y)
  |> yielder.map(fn(y) {
    yielder.range(0, grid.max_x)
    |> yielder.map(fn(x) {
      let c = #(y, x)
      let assert Ok(v) = dict.get(grid.matrix, c)

      transform(v)
    })
    |> yielder.to_list
    |> string.join("")
  })
  |> yielder.to_list
  |> string.join("\n")
}

pub fn draw_grid(grid: GridS) -> GridS {
  io.println("")
  draw_grid_transform(grid, fn(x) { x })
  io.println("")
  grid
}

pub fn draw_grid_transform(grid: Grid(value), transform: fn(value) -> String) {
  io.println("")
  io.println(stringify_grid_transform(grid, transform))
  io.println("")
  grid
}

pub fn contains(grid: Grid(_), coord: Coord) -> Bool {
  let #(y, x) = coord

  y >= 0 && x >= 0 && y <= grid.max_y && x <= grid.max_x
}

pub fn add(a: Coord, b: Coord) -> Coord {
  #(a.0 + b.0, a.1 + b.1)
}

pub fn sub(a: Coord, b: Coord) -> Coord {
  #(a.0 - b.0, a.1 - b.1)
}

pub fn neg(a: Coord) -> Coord {
  #(-a.0, -a.1)
}

pub fn up(c: Coord) -> Coord {
  #(c.0 - 1, c.1)
}

pub fn down(c: Coord) -> Coord {
  #(c.0 + 1, c.1)
}

pub fn left(c: Coord) -> Coord {
  #(c.0, c.1 - 1)
}

pub fn right(c: Coord) -> Coord {
  #(c.0, c.1 + 1)
}

pub fn move_cardinals(c: Coord) -> List(Coord) {
  [up(c), down(c), left(c), right(c)]
}

pub fn move(c: Coord, dir: Cardinal) {
  case dir {
    Up -> up(c)
    Down -> down(c)
    Left -> left(c)
    Right -> right(c)
  }
}

pub fn move_card_intercard(c: Coord) -> List(Coord) {
  [
    up(c),
    c |> up |> right,
    right(c),
    c |> down |> right,
    down(c),
    c |> down |> left,
    left(c),
    c |> up |> left,
  ]
}
