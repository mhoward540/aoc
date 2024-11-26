import gleam/int
import gleam/io
import gleam/list
import gleam/string

fn parse_input(input: String) -> List(String) {
  string.split(input, ",")
}

fn run_hash(s: String) -> Int {
  s
  |> string.split("")
  |> list.map(string.to_utf_codepoints)
  |> list.flatten
  |> list.map(string.utf_codepoint_to_int)
  |> list.fold(0, fn(codepoint, acc){
    { {acc + codepoint} * 17} % 256
  })
}

pub fn pt_1(input: String) {
  input
  |> parse_input
  |> list.map(run_hash)
  |> int.sum
}

pub fn pt_2(input: String) {
  todo as "part 2 not implemented"
}
