import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/string

fn parse_input(s: String) -> #(List(Int), List(Int)) {
  s
  |> string.split("\n")
  |> list.fold(#([], []), fn(acc, line) {
    let assert [a, b] = string.split(line, "   ")
    let assert Ok(a) = int.parse(a)
    let assert Ok(b) = int.parse(b)

    #([a, ..acc.0], [b, ..acc.1])
  })
}

fn sort_and_diff(left: List(Int), right: List(Int)) -> Int {
  let left = list.sort(left, int.compare)
  let right = list.sort(right, int.compare)

  list.map2(left, right, fn(a, b) { int.absolute_value(a - b) })
  |> int.sum
}

fn increment(x) {
  case x {
    option.Some(i) -> i + 1
    option.None -> 1
  }
}

// is somebody gonna match my freq?
fn similarity_score(left: List(Int), right: List(Int)) -> Int {
  let freq =
    right
    |> list.fold(dict.new(), fn(d, num) { dict.upsert(d, num, increment) })

  // io.debug(freq)

  list.map(left, fn(num) {
    let num_freq = dict.get(freq, num)
    let mult = case num_freq {
      Ok(i) -> i
      Error(_) -> 0
    }

    mult * num
  })
  // |> io.debug
  |> int.sum
}

pub fn pt_1(input: String) {
  let #(left, right) =
    input
    |> parse_input

  sort_and_diff(left, right)
}

pub fn pt_2(input: String) {
  let #(left, right) =
    input
    |> parse_input

  similarity_score(left, right)
}
