import gleam/dict
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
      case b - a {
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

// Get all sublists of size (len(row) - 1)
fn get_sublists(row: List(Int)) -> List(List(Int)) {
  let l = list.length(row)
  let d =
    row
    |> list.index_map(fn(x, i) { #(i, x) })
    |> dict.from_list

  list.range(0, l - 1)
  |> list.combinations(l - 1)
  |> list.map(fn(l) {
    l
    |> list.map(fn(i) {
      let assert Ok(num) = dict.get(d, i)
      num
    })
  })
}

fn is_safe_with_dampening(row: List(Int)) -> Bool {
  let row_safe = is_safe(row)

  case row_safe {
    True -> True
    False -> {
      // Brute force, why not
      row
      |> get_sublists
      |> list.map(is_safe)
      |> list.any(fn(x) { x })
    }
  }
}

pub fn pt_1(input: String) {
  input
  |> parse_input
  |> list.map(is_safe)
  |> list.count(fn(x) { x })
}

pub fn pt_2(input: String) {
  input
  |> parse_input
  |> list.map(is_safe_with_dampening)
  |> list.count(fn(x) { x })
}
