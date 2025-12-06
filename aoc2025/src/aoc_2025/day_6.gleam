import aoc_util/util
import gleam/dict
import gleam/int
import gleam/list
import gleam/set
import gleam/string

fn parse_input(input: String) {
  let lines =
    input
    |> string.split("\n")

  let assert [operations, ..lines] = lines |> list.reverse
  let lines = lines |> list.reverse
  let operations =
    operations
    |> string.to_graphemes
    |> list.filter(fn(c) { c != " " })

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

fn do_part(input: String, process_col: fn(List(String)) -> List(Int)) {
  let #(lines, operations) =
    input
    |> parse_input

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
    |> list.map(process_col)

  list.map2(cols, operations, fn(col, operation) {
    let assert Ok(res) =
      col
      |> list.reduce(operation)

    res
  })
  |> int.sum
}

pub fn pt_1(input: String) {
  do_part(input, transform_col)
}

pub fn pt_2(input: String) {
  do_part(input, transform_col2)
}
