import gleam/bool
import gleam/float
import gleam/int
import gleam/list
import gleam/result
import gleam/string
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

// using math
fn is_invalid2(num: Int) -> Bool {
  use <- bool.guard(num < 10 && num >= 0, False)

  let len =
    int.to_float(num)
    |> maths.logarithm_10()
    |> result.unwrap(0.0)
    |> float.floor
    |> float.round
    |> int.add(1)

  use <- bool.guard(int.modulo(len, 2) == Ok(1), False)
  let assert Ok(half_len) = int.divide(len, 2)
  let assert Ok(p) = int.power(10, half_len |> int.to_float)
  let p = p |> float.round
  let assert Ok(l) = int.divide(num, p)
  let assert Ok(r) = int.modulo(num, p)

  l == r
}

fn is_invalid(num_s: String) -> Bool {
  let len = num_s |> string.length
  use <- bool.guard(len == 1, False)
  use <- bool.guard(int.modulo(len, 2) == Ok(1), False)
  let assert Ok(half_len) = int.divide(len, 2)
  let l = string.slice(num_s, 0, half_len)
  let r = string.slice(num_s, half_len, len + 1)

  l == r
}

fn list_invalids(range: PidRange) -> List(Int) {
  // TODO maybe do log10 here instead
  let start_len = range.start_s |> string.length
  let end_len = range.end_s |> string.length
  use <- bool.guard(
    int.modulo(start_len, 2) == Ok(1) && int.modulo(end_len, 2) == Ok(1),
    [],
  )
  list.range(range.start, range.end)
  |> list.filter(fn(num) {
    num
    |> int.to_string
    |> is_invalid
  })
}

pub fn pt_1(input: String) {
  input
  |> parse_input
  |> list.flat_map(list_invalids)
  |> list.fold(0, fn(a, b) { a + b })
}

// 54234399969 is too high?
pub fn pt_2(input: String) {
  todo as "part 2 not implemented"
}
