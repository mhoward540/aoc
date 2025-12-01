import gleam/int
import gleam/list
import gleam/string

type Turn {
  Left(distance: Int)
  Right(distance: Int)
}

fn parse_line(line: String) {
  let assert Ok(direction) = string.first(line)
  let assert Ok(distance) = string.slice(line, 1, 100_000) |> int.parse

  case direction {
    "L" -> Left(distance)
    "R" -> Right(distance)
    _ -> panic as "Unrecognized turn"
  }
}

fn parse_input(input: String) {
  input
  |> string.split("\n")
  |> list.map(parse_line)
}

fn simulate_turns(turns: List(Turn), start_index: Int, max_dial: Int) -> Int {
  let res =
    turns
    |> list.fold(#(0, start_index), fn(t, curr_turn) {
      let #(zero_count, curr_index) = t

      let distance = case curr_turn {
        Left(d) -> -1 * d
        Right(d) -> d
      }

      let assert Ok(new_index) = int.modulo(curr_index + distance, max_dial + 1)

      let new_z_count = case new_index {
        0 -> zero_count + 1
        _ -> zero_count
      }

      #(new_z_count, new_index)
    })

  res.0
}

pub fn pt_1(input: String) {
  input
  |> parse_input
  |> simulate_turns(50, 99)
}

pub fn pt_2(input: String) {
  todo as "part 2 not implemented"
}
