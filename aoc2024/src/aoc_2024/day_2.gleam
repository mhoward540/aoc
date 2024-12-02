import gleam/int
import gleam/io
import gleam/list
import gleam/string

fn parse_line(line: String) -> List(Int) {
  line
  |> string.split(" ")
  |> list.map(fn(item) {
    let assert Ok(item) = int.parse(item)
    item
  })
}

fn parse_input(input: String) -> List(List(Int)) {
  input
  |> string.split("\n")
  |> list.map(parse_line)
  |> io.debug
}

fn is_safe(row: List(Int)) -> Bool {
  let is_increasing_safe =
    row
    |> list.window_by_2
    |> list.map(fn(chunk) {
      let #(a, b) = chunk
      case b - a |> io.debug {
        -1 | -2 | -3 -> True
        _ -> False
      }
    })
    |> list.all(fn(x) { x })

  let is_decreasing_safe =
    row
    |> list.window_by_2
    |> list.map(fn(chunk) {
      let #(a, b) = chunk
      case b - a {
        1 | 2 | 3 -> True
        _ -> False
      }
    })
    |> list.all(fn(x) { x })
  
  is_decreasing_safe || is_increasing_safe
}

pub fn pt_1(input: String) {
  input
  |> parse_input
  |> list.map(is_safe)
  |> list.count(fn(x) {x})
}

pub fn pt_2(input: String) {
  todo as "part 2 not implemented"
}
