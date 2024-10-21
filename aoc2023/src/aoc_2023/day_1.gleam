import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub type Day1Errors {
  NotEnoughNums
  NotParseableAsNum
}

fn parse_one(
  index_of_char: Int,
  window: List(String),
) -> Result(#(Int, Int), Day1Errors) {
  let character = result.unwrap(list.first(window), "")
  case int.parse(character) {
    Ok(x) -> Ok(#(index_of_char, x))
    Error(_) -> Error(NotParseableAsNum)
  }
}

fn parse_three(
  index_of_char: Int,
  window: List(String),
) -> Result(#(Int, Int), Day1Errors) {
  let s = string.join(window, "")
  let v = case s {
    "one" -> 1
    "two" -> 2
    "six" -> 6
    _ -> -1
  }

  case v {
    -1 -> Error(NotParseableAsNum)
    x -> Ok(#(index_of_char, x))
  }
}

fn parse_four(
  index_of_char: Int,
  window: List(String),
) -> Result(#(Int, Int), Day1Errors) {
  let s = string.join(window, "")
  let v = case s {
    "four" -> 4
    "five" -> 5
    "nine" -> 9
    _ -> -1
  }

  case v {
    -1 -> Error(NotParseableAsNum)
    x -> Ok(#(index_of_char, x))
  }
}

fn parse_five(
  index_of_char: Int,
  window: List(String),
) -> Result(#(Int, Int), Day1Errors) {
  let s = string.join(window, "")
  let v = case s {
    "three" -> 3
    "seven" -> 7
    "eight" -> 8
    _ -> -1
  }

  case v {
    -1 -> Error(NotParseableAsNum)
    x -> Ok(#(index_of_char, x))
  }
}

// Get all parsed numbers, in order, for a given line
fn parsed_nums_for_line(line: String) {
  let str_spl = string.split(line, on: "")

  let parse_for_window = fn(
    x: #(Int, fn(Int, List(String)) -> Result(#(Int, Int), Day1Errors)),
  ) {
    let #(window_size, parse_fn) = x
    list.window(str_spl, by: window_size)
    |> list.index_map(fn(i, l) { parse_fn(l, i) })
  }

  [#(5, parse_five), #(4, parse_four), #(3, parse_three), #(1, parse_one)]
  |> list.map(parse_for_window)
  |> list.concat
  |> result.values
  |> list.sort(fn(a, b) { int.compare(a.0, b.0) })
  |> list.map(fn(a) { a.1 })
}

fn nums_for_line(line: String) {
  line
  |> string.split(on: "")
  |> list.filter_map(int.parse)
}

fn sum_for_line(line: List(Int)) {
  case line {
    [] -> Error(NotEnoughNums)
    rest ->
      Ok(
        { result.unwrap(list.first(rest), 0) * 10 }
        + result.unwrap(list.last(rest), 0),
      )
  }
}

pub fn pt_1(input: String) {
  input
  |> string.split(on: "\n")
  |> list.map(nums_for_line)
  |> list.filter_map(sum_for_line)
  |> list.fold(0, int.add)
}

pub fn pt_2(input: String) {
  input
  |> string.split(on: "\n")
  |> list.map(parsed_nums_for_line)
  |> list.filter_map(sum_for_line)
  |> list.fold(0, int.add)
}
