import gleam/io
import gleam/int
import gleam/list
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
  
  
  list.map2(left, right, fn(a, b) {
    int.absolute_value(a - b)
  })
  |> int.sum
}

pub fn pt_1(input: String) {
  let #(left, right) = input
  |> parse_input
  
  sort_and_diff(left, right)
}

pub fn pt_2(input: String) {
  todo as "part 2 not implemented"
}
