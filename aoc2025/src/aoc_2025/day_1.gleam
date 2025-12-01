import gleam/float
import gleam/int
import gleam/list
import gleam/order
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

fn simulate_passes(turns: List(Turn), start_index: Int, max_dial: Int) -> Int {
  let res =
    turns
    |> list.fold(#(0, start_index), fn(t, curr_turn) {
      let #(zero_passes, curr_index) = t

      let assert Ok(extra_passes) = int.divide(curr_turn.distance, max_dial + 1)
      let assert Ok(rem_distance) = int.modulo(curr_turn.distance, max_dial + 1)

      let zero_passes = zero_passes + extra_passes
      let d = case curr_turn {
        Left(_) -> -1 * rem_distance
        Right(_) -> rem_distance
      }

      let n = curr_index + d

      // if we are already on zero and we move, do not count it as passing zero again since landing on zero already counts
      let zero_passes = case n, curr_index {
        nn, _ if nn >= { max_dial + 1 } -> zero_passes + 1
        nn, dd if nn <= 0 && dd != 0 -> zero_passes + 1
        _, _ -> zero_passes
      }

      let new_mag = case curr_turn {
        Left(ctd) -> int.negate(ctd)
        Right(ctd) -> ctd
      }

      let assert Ok(new_index) =
        new_mag
        |> int.add(curr_index)
        |> int.modulo(max_dial + 1)

      #(zero_passes, new_index)
    })

  res.0
}

pub fn pt_1(input: String) {
  input
  |> parse_input
  |> simulate_turns(50, 99)
}

// 7077 is too high
pub fn pt_2(input: String) {
  input
  |> parse_input
  |> simulate_passes(50, 99)
}
