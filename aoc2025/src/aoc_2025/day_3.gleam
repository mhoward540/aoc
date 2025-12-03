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

fn find_joltage(acc_t: #(Int, Int), curr_t: #(Int, Int)) {
  let #(max, _) = acc_t
  let #(curr_joltage, index) = curr_t

  case int.compare(curr_joltage, max) {
    order.Gt -> #(curr_joltage, index)
    order.Lt -> acc_t
    order.Eq -> acc_t
  }
}

fn get_row_joltage(row: List(Int)) {
  let l_row =
    row
    |> list.reverse

  let assert [_, ..l_row] = l_row
  let l_row = l_row |> list.reverse

  let #(l, l_index) =
    l_row
    |> list.index_map(fn(x, i) { #(x, i) })
    |> list.fold(#(-1, -1), find_joltage)

  let #(r, _) =
    row
    |> list.index_map(fn(x, i) { #(x, i) })
    |> list.drop_while(fn(t) { t.1 <= l_index })
    |> list.fold(#(-1, -1), find_joltage)

  echo #(l, r)
  echo ""

  { l * 10 } + r
}

pub fn pt_1(input: String) {
  input
  |> parse_input
  |> list.map(get_row_joltage)
  |> int.sum
}

pub fn pt_2(input: String) {
  todo as "part 2 not implemented"
}
