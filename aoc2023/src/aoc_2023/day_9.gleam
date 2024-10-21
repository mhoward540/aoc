import gleam/string
import gleam/iterator
import gleam/list
import gleam/int

fn parse_line(line: String) -> List(Int) {
  line
  |> string.split(" ")
  |> list.map(fn(num_str) {
    let assert Ok(num) = int.parse(num_str)
    num
  })
}

fn parse_input(input: String) -> List(List(Int)) {
  input
  |> string.split(on: "\n")
  |> list.map(parse_line)
}

fn generate_differences_lists(nums: List(Int)) {
  // Iterator which keeps calculating the differences of each window of 2 numbers in the list
  let iter =
    iterator.iterate(
      nums,
      fn(curr_nums) {
        curr_nums
        |> list.window_by_2
        |> list.map(fn(window) { window.1 - window.0 })
      },
    )

  // Keep the iterator going until the whole list is zeros and return the list
  iter
  |> iterator.take_while(satisfying: fn(curr_nums) {
    list.any(curr_nums, fn(num) { num != 0 })
  })
  |> iterator.to_list
}

fn extrapolate_next_value(step_differences: List(List(Int))) {
  // Sum the last numbers in each list
  step_differences
  |> list.map(fn(curr_differences) {
    let assert Ok(last_num) = list.last(curr_differences)
    last_num
  })
  |> list.fold(0, int.add)
}

fn extrapolate_earlier_value(step_differences: List(List(Int))) {
  step_differences
  |> list.map(fn(curr_differences) {
    let assert Ok(first_num) = list.first(curr_differences)
    first_num
  })
  |> list.reverse
  |> list.fold(0, fn(x, y) { int.subtract(y, x) })
}

pub fn pt_1(input: String) {
  input
  |> parse_input
  |> list.map(generate_differences_lists)
  |> list.map(extrapolate_next_value)
  |> list.fold(0, int.add)
}

pub fn pt_2(input: String) {
  input
  |> parse_input
  |> list.map(generate_differences_lists)
  |> list.map(extrapolate_earlier_value)
  |> list.fold(0, int.add)
}
