import aoc_util/gridutil.{type GridS}
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/regexp
import gleam/string

fn parse_input(input: String) -> GridS {
  let assert Ok(whitespace) = regexp.from_string(" {2,}")
  let matrix =
    input
    |> regexp.replace(whitespace, _, " ")
    |> string.split("\n")
    |> list.index_map(fn(line, y) {
      io.println(line)

      line
      |> string.trim
      |> string.split(" ")
      |> list.index_map(fn(entry, x) { #(#(y, x), entry) })
    })
    |> list.flatten

  let assert Ok(#(#(height, width), _)) = list.last(matrix)
  let matrix = dict.from_list(matrix)

  gridutil.Grid(matrix: matrix, max_y: height, max_x: width)
}

fn do_operations(grid: GridS) -> List(Int) {
  list.range(0, grid.max_x)
  |> list.map(fn(x) {
    let assert Ok(operation_s) = dict.get(grid.matrix, #(grid.max_y, x))
    let acc = case operation_s {
      "*" -> fn(a, b) { a * b }
      "+" -> fn(a, b) { a + b }
      _ -> panic as "unknown operation"
    }

    let assert Ok(res) =
      list.range(0, grid.max_y - 1)
      |> list.map(fn(y) {
        let assert Ok(num) = dict.get(grid.matrix, #(y, x))
        let assert Ok(num) = int.parse(num)
        num
      })
      |> list.reduce(acc)

    res
  })
}

pub fn pt_1(input: String) {
  input
  |> parse_input
  |> do_operations
  |> int.sum
}

pub fn pt_2(input: String) {
  todo as "part 2 not implemented"
}
