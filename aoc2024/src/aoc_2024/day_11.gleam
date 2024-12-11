import gleam/bool
import gleam/int
import gleam/list
import gleam/result
import gleam/string

fn parse_input(input: String) -> List(Int) {
  input
  |> string.split(" ")
  |> list.map(int.parse)
  |> result.values
}

fn count_and_split_digits(stone: Int) -> #(Int, List(Int)) {
  use <- bool.guard(stone < 10, #(1, [stone]))
  let s_stone = int.to_string(stone)

  let len = string.length(s_stone)
  let assert Ok(half_len) = int.divide(len, 2)

  let left_s = string.slice(s_stone, 0, half_len)
  let right_s = string.slice(s_stone, half_len, half_len)

  let assert Ok(left) = int.parse(left_s)
  let assert Ok(right) = int.parse(right_s)

  #(len, [left, right])
}

fn replace_stone(stone: Int) -> List(Int) {
  let #(len, lr_digits) = count_and_split_digits(stone)
  case stone, len % 2 == 0 {
    0, _ -> [1]
    _, True -> lr_digits
    _, _ -> [stone * 2024]
  }
}

fn naive_replace_stones(stones: List(Int)) -> List(Int) {
  stones
  |> list.flat_map(replace_stone)
}

pub fn pt_1(input: String) {
  let stones =
    input
    |> parse_input

  list.range(1, 25)
  |> list.fold(stones, fn(acc, _) { 
    naive_replace_stones(acc)
  })
  |> list.length
}

pub fn pt_2(input: String) {
  todo as "part 2 not implemented"
}
