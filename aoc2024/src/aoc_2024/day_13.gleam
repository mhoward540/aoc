import gleam/bool
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/option
import gleam/regex
import gleam/string

type Button {
  Button(x: Int, y: Int)
}

type Prize {
  Prize(x: Int, y: Int)
}

type Machine {
  Machine(a: Button, b: Button, prize: Prize)
}

fn parse_input(input: String) -> List(Machine) {
  let assert Ok(button_pattern) =
    regex.compile(
      "Button .: X\\+(\\d+), Y\\+(\\d+)",
      regex.Options(case_insensitive: False, multi_line: False),
    )

  let assert Ok(prize_pattern) =
    regex.compile(
      "Prize: X=(\\d+), Y=(\\d+)",
      regex.Options(case_insensitive: False, multi_line: False),
    )

  input
  |> string.split("\n\n")
  |> list.map(fn(section) {
    let assert [a_string, b_string, prize_string] = string.split(section, "\n")

    let assert [a_t, b_t, prize_t] =
      [
        #(a_string, button_pattern),
        #(b_string, button_pattern),
        #(prize_string, prize_pattern),
      ]
      |> list.map(fn(t) {
        let #(s, pattern) = t
        let assert Ok(match) = regex.scan(pattern, s) |> list.first

        let assert Ok(x_match) = list.first(match.submatches)
        let assert Ok(y_match) = list.last(match.submatches)
        let x_str = option.lazy_unwrap(x_match, fn() { panic })
        let y_str = option.lazy_unwrap(y_match, fn() { panic })
        let assert Ok(x) = int.parse(x_str)
        let assert Ok(y) = int.parse(y_str)

        #(x, y)
      })

    let a_button = Button(a_t.0, a_t.1)
    let b_button = Button(b_t.0, b_t.1)
    let prize = Prize(prize_t.0, prize_t.1)

    Machine(a_button, b_button, prize)
  })
}

fn is_valid_solution(a_presses: Int, b_presses: Int, machine: Machine) -> Bool {
  let ax = a_presses * machine.a.x
  let ay = a_presses * machine.a.y
  let bx = b_presses * machine.b.x
  let by = b_presses * machine.b.y
  { ax + bx } == machine.prize.x && { ay + by } == machine.prize.y
}

fn brute_force_buttons(machine: Machine, start: Int, end: Int) -> Int {
  let solutions =
    iterator.range(start, end)
    |> iterator.flat_map(fn(a) {
      iterator.range(start, end)
      |> iterator.map(fn(b) { #(a, b) })
    })
    |> iterator.filter(fn(t) { is_valid_solution(t.0, t.1, machine) })
    |> iterator.to_list

  case list.is_empty(solutions) {
    True -> 0
    False -> {
      solutions
      |> list.map(fn(t) { { t.0 * 3 } + t.1 })
      |> list.fold(9_999_999_999, int.min)
    }
  }
}

fn lin_alg_buttons(machine: Machine) {
  let prize = machine.prize
  let a = machine.a
  let b = machine.b
  let pybx_pxby = prize.y * b.x - prize.x * b.y

  let bxay_axby = b.x * a.y - a.x * b.y
  let presses_a = pybx_pxby / bxay_axby
  use <- bool.guard(pybx_pxby % bxay_axby != 0, 0)
  let presses_b = { prize.y - presses_a * a.y } / b.y

  case { prize.y - presses_a * a.y } % b.y == 0 {
    True -> { 3 * presses_a } + presses_b
    False -> 0
  }
}

pub fn pt_1(input: String) {
  input
  |> parse_input
  |> list.map(lin_alg_buttons)
  |> int.sum
}

pub fn pt_2(input: String) {
  input
  |> parse_input
  |> list.map(fn(machine) {
    Machine(
      machine.a,
      machine.b,
      Prize(
        machine.prize.x + 10_000_000_000_000,
        machine.prize.y + 10_000_000_000_000,
      ),
    )
  })
  |> list.map(lin_alg_buttons)
  |> int.sum
}
