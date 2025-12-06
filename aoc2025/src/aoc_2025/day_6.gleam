import aoc_util/gridutil.{type GridS}
import aoc_util/util
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/regexp
import gleam/set
import gleam/string

fn parse_input3(input: String) {
  let lines =
    input
    |> string.split("\n")

  let assert [operations, ..lines] = lines |> list.reverse
  let lines = lines |> list.reverse
  let operations =
    operations
    |> string.to_graphemes
    |> list.filter(fn(c) { c != " " })

  echo operations

  let assert Ok(separators) =
    lines
    |> list.map(fn(line) {
      let spl = string.to_graphemes(line)
      util.all_indices_of(" ", spl)
      |> set.from_list
    })
    |> list.reduce(set.intersection)

  let separators =
    separators
    |> set.to_list

  let split_lines =
    lines
    |> list.map(util.split_at_indices(_, separators))

  #(split_lines, operations)
}

fn parse_input(input: String) -> GridS {
  let assert Ok(whitespace) = regexp.from_string(" {2,}")
  let matrix =
    input
    |> regexp.replace(whitespace, _, " ")
    |> string.split("\n")
    |> list.index_map(fn(line, y) {
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

fn parse_input2(input: String) {
  let assert Ok(whitespace) = regexp.from_string(" *\\d+ ?")
  let lines =
    input
    |> string.split("\n")

  //TODO fix
  let assert [ops_line, ..lines] = list.reverse(lines)
  let lines = list.reverse(lines)

  let cols =
    lines
    |> list.map(fn(line) {
      regexp.scan(whitespace, line)
      |> list.index_map(fn(match, i) { #(i, match.content) })
    })
    |> list.flatten
    |> list.fold(dict.new(), fn(acc, t) {
      let #(i, s) = t
      case dict.get(acc, i) {
        Ok(l) -> dict.insert(acc, i, [s, ..l])
        Error(_) -> dict.insert(acc, i, [s])
      }
    })

  #(cols, ops_line)
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

fn parse_col(col: List(String)) {
  echo ""
  echo col
  echo col
    |> list.map(fn(s) {
      string.split(s, "")
      |> list.index_map(fn(c, i) { #(i, c) })
    })
    |> list.flatten
    |> list.fold(dict.new(), fn(acc, t) {
      let #(i, s) = t
      case dict.get(acc, i) {
        Ok(l) -> dict.insert(acc, i, [s, ..l])
        Error(_) -> dict.insert(acc, i, [s])
      }
    })
    |> dict.map_values(fn(_, l) {
      l
      |> string.join("")
      // |> string.trim
      // |> int.parse
    })
}

fn transform_col(col: List(String)) -> List(Int) {
  col
  |> list.map(fn(num) {
    let num = num |> string.trim
    let assert Ok(num) = int.parse(num)
    num
  })
}

fn transform_col2(col: List(String)) {
  col
  |> list.map(fn(s) {
    s
    |> string.to_graphemes
    |> list.index_map(fn(c, i) { #(i, c) })
  })
  |> list.flatten
  |> util.group_maintaining_order
  |> dict.values
  |> list.filter_map(fn(s) {
    s
    |> string.join("")
    |> string.trim
    |> int.parse
  })
}

pub fn pt_1(input: String) {
  let #(lines, operations) =
    input
    |> parse_input3

  let operations =
    operations
    |> list.map(fn(op) {
      case op {
        "*" -> fn(a, b) { a * b }
        "+" -> fn(a, b) { a + b }
        _ -> panic as "Unknown operation"
      }
    })

  let cols =
    lines
    |> util.cols
    |> list.map(transform_col)

  list.map2(cols, operations, fn(col, operation) {
    let assert Ok(res) =
      col
      |> list.reduce(operation)

    res
  })
  |> int.sum
}

pub fn pt_2(input: String) {
  let #(lines, operations) =
    input
    |> parse_input3

  let operations =
    operations
    |> list.map(fn(op) {
      case op {
        "*" -> fn(a, b) { a * b }
        "+" -> fn(a, b) { a + b }
        _ -> panic as "Unknown operation"
      }
    })

  let cols =
    lines
    |> util.cols
    |> list.map(transform_col2)

  list.map2(cols, operations, fn(col, operation) {
    let assert Ok(res) =
      col
      |> list.reduce(operation)

    res
  })
  |> int.sum
}
// pub fn pt_2(input: String) {
//   let #(cols, ops) =
//     input
//     |> parse_input2

//   cols
//   |> dict.values
//   |> list.map(parse_col)

//   ""
// }
