import gleam/bool
import gleam/int
import gleam/list
import gleam/order
import gleam/string

fn parse_input(input: String) -> List(List(Int)) {
  input
  |> string.split("\n")
  |> list.map(fn(line) {
    line
    |> string.to_graphemes
    |> list.map(fn(c) {
      let assert Ok(num) = int.parse(c)
      num
    })
  })
}

fn get_joltage_digits(
  row: List(Int),
  len: Int,
  remaining_to_find: Int,
  digits: List(Int),
) {
  let #(digit, digit_index) =
    row
    |> list.index_map(fn(x, i) { #(x, i) })
    |> list.fold_until(#(-1, -1), fn(acc_t, curr_t) {
      let #(curr, index) = curr_t
      use <- bool.guard(
        index == { len - remaining_to_find + 1 },
        list.Stop(acc_t),
      )
      use <- bool.guard(curr == 9, list.Stop(curr_t))

      case int.compare(curr, acc_t.0) {
        order.Gt -> list.Continue(curr_t)
        order.Lt -> list.Continue(acc_t)
        order.Eq -> list.Continue(acc_t)
      }
    })

  let digits = [digit, ..digits]
  let remaining_to_find = remaining_to_find - 1
  case remaining_to_find {
    0 -> digits |> list.reverse
    _ -> {
      let row = list.drop(row, digit_index + 1)
      get_joltage_digits(
        row,
        len - { digit_index + 1 },
        remaining_to_find,
        digits,
      )
    }
  }
}

fn join(digits: List(Int)) -> Int {
  let assert Ok(out) =
    digits
    |> list.map(int.to_string)
    |> string.join("")
    |> int.parse

  out
}

fn get_joltage_of_length(row: List(Int), n: Int) {
  let len = list.length(row)
  let digits = get_joltage_digits(row, len, n, [])

  join(digits)
}

pub fn pt_1(input: String) {
  input
  |> parse_input
  |> list.map(get_joltage_of_length(_, 2))
  |> int.sum
}

pub fn pt_2(input: String) {
  input
  |> parse_input
  |> list.map(get_joltage_of_length(_, 12))
  |> int.sum
}
