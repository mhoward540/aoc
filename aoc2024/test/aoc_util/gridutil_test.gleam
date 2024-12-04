import gleam/int
import aoc_util/gridutil
import gleam/dict
import gleam/list
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn to_grid_test() {
  // given
  let sut = "123\n456\n789"

  // when
  let grid = gridutil.to_grid(sut)

  // then
  let coords =
    grid.matrix
    |> dict.to_list
    |> list.sort(fn(a, b) { gridutil.coord_compare(a.0, b.0) })

  should.equal(coords, [
    #(#(0, 0), "1"),
    #(#(0, 1), "2"),
    #(#(0, 2), "3"),
    #(#(1, 0), "4"),
    #(#(1, 1), "5"),
    #(#(1, 2), "6"),
    #(#(2, 0), "7"),
    #(#(2, 1), "8"),
    #(#(2, 2), "9"),
  ])
  
  should.equal(grid.max_y, 2)
  should.equal(grid.max_x, 2)
}

pub fn to_grid_transform_test() {
  // given
  let sut = "123\n456\n789"

  // when
  let grid = gridutil.to_grid_transform(sut, fn(x) {
    let assert Ok(num) = int.parse(x)
    num
  })

  // then
  let coords =
    grid.matrix
    |> dict.to_list
    |> list.sort(fn(a, b) { gridutil.coord_compare(a.0, b.0) })

  should.equal(coords, [
    #(#(0, 0), 1),
    #(#(0, 1), 2),
    #(#(0, 2), 3),
    #(#(1, 0), 4),
    #(#(1, 1), 5),
    #(#(1, 2), 6),
    #(#(2, 0), 7),
    #(#(2, 1), 8),
    #(#(2, 2), 9),
  ])
  
  should.equal(grid.max_y, 2)
  should.equal(grid.max_x, 2)
}

pub fn get_cols_test() {
  // given
  let sut = "123\n456\n789"

  // when
  let grid = gridutil.to_grid(sut)

  // then
  let cols =
    grid
    |> gridutil.get_cols

  should.equal(cols, [
    ["1", "4", "7"],
    ["2", "5", "8"],
    ["3", "6", "9"],
  ])
}

pub fn get_cols_joined_test() {
  // given
  let sut = "123\n456\n789"

  // when
  let grid = gridutil.to_grid(sut)

  // then
  let cols =
    grid
    |> gridutil.get_cols_joined

  should.equal(cols, [
    "147",
    "258",
    "369"
  ])
}

pub fn get_rows_test() {
  // given
  let sut = "123\n456\n789"

  // when
  let grid = gridutil.to_grid(sut)

  // then
  let rows =
    grid
    |> gridutil.get_rows

  should.equal(rows, [
    ["1", "2", "3"],
    ["4", "5", "6"],
    ["7", "8", "9"],
  ])
}

pub fn get_rows_joined_test() {
  // given
  let sut = "123\n456\n789"

  // when
  let grid = gridutil.to_grid(sut)

  // then
  let rows =
    grid
    |> gridutil.get_rows_joined

  should.equal(rows, [
    "123",
    "456",
    "789"
  ])
}