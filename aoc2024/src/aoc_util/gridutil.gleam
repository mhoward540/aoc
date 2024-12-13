import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/iterator.{type Iterator}
import gleam/list
import gleam/order.{type Order}
import gleam/string

pub type Coord =
  #(Int, Int)

pub type Matrix(value) =
  Dict(Coord, value)

pub type Grid(value) {
  Grid(matrix: Matrix(value), max_y: Int, max_x: Int)
}

pub type GridS =
  Grid(String)

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

pub fn iter_grid(grid: Grid(value)) -> Iterator(#(Coord, value)) {
  iterator.range(0, grid.max_y)
  |> iterator.map(fn(y) {
    iterator.range(0, grid.max_x)
    |> iterator.map(fn(x) {
      let c = #(y, x)
      let assert Ok(v) = dict.get(grid.matrix, c)
      #(c, v)
    })
  })
  |> iterator.flatten
}

pub fn draw_grid(grid: GridS) -> GridS {
  io.debug("")
  iterator.range(0, grid.max_y)
  |> iterator.map(fn(y) {
    iterator.range(0, grid.max_x)
    |> iterator.map(fn(x) {
      let c = #(y, x)
      let assert Ok(v) = dict.get(grid.matrix, c)

      v
    })
    |> iterator.to_list
    |> string.join("")
  })
  |> iterator.to_list
  |> list.map(io.debug)

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
  [
    up(c),
    down(c),
    left(c),
    right(c)
  ]
}