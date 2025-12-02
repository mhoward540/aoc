import gleam/bool
import gleam/int
import gleam/list
import gleam/set
import gleam/string
import gleam/yielder.{type Yielder}
import gleam_community/maths

type PidRange {
  PidRange(start: Int, end: Int, start_s: String, end_s: String)
}

fn parse_input(input: String) -> List(PidRange) {
  input
  |> string.split("\n")
  |> string.concat
  |> string.split(",")
  |> list.map(fn(r) {
    // echo r
    let assert [start_s, end_s] = string.split(r, "-")
    let assert Ok(start) = int.parse(start_s)
    let assert Ok(end) = int.parse(end_s)

    PidRange(start, end, start_s, end_s)
  })
}

fn is_invalid(num: Int) -> Bool {
  let num_s = int.to_string(num)
  let len = num_s |> string.length
  use <- bool.guard(len == 1, False)
  use <- bool.guard(int.modulo(len, 2) == Ok(1), False)
  let assert Ok(half_len) = int.divide(len, 2)
  let l = string.slice(num_s, 0, half_len)
  let r = string.slice(num_s, half_len, len + 1)

  l == r
}

fn get_even_splits(s: String) -> Yielder(List(String)) {
  let len = string.length(s)
  let split_lens = maths.divisors(len) |> list.filter(fn(x) { x != len })

  split_lens
  |> yielder.from_list
  |> yielder.map(split_evenly_by(s, len, _))
}

fn is_really_invalid(num: Int) -> Bool {
  num
  |> int.to_string
  |> get_even_splits
  |> yielder.any(fn(l) {
    case set.size(set.from_list(l)) == 1 {
      True -> {
        // echo #(num, l)
        True
      }
      False -> False
    }
  })
}

fn list_invalids(range: PidRange, test_invalid: fn(Int) -> Bool) -> List(Int) {
  list.range(range.start, range.end)
  |> list.filter(test_invalid)
}

fn sum_invalids(range: PidRange, test_invalid: fn(Int) -> Bool) -> Int {
  list_invalids(range, test_invalid)
  |> int.sum
}

fn split_evenly_by(s: String, len: Int, split_dist: Int) -> List(String) {
  yielder.unfold(s, fn(remaining_s) {
    case string.length(remaining_s) {
      0 -> yielder.Done
      _ -> {
        let curr =
          remaining_s
          |> string.to_graphemes
          |> yielder.from_list
          |> yielder.take(split_dist)
          |> yielder.to_list
          |> string.join(with: "")

        let next = string.slice(remaining_s, split_dist, len)

        yielder.Next(curr, next)
      }
    }
  })
  |> yielder.to_list
}

pub fn pt_1(input: String) {
  input
  |> parse_input
  |> list.map(sum_invalids(_, is_invalid))
  |> int.sum
}

pub fn pt_2(input: String) {
  input
  |> parse_input
  |> list.map(sum_invalids(_, is_really_invalid))
  |> int.sum
}
