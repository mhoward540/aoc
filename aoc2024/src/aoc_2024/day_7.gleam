import gleam/order
import gleam/bool
import gleam/io
import gleam/list
import gleam/int
import gleam/string

type Calibration {
  Calibration(target: Int, equation: List(Int))
}

fn parse_line(line: String) -> Calibration {
  let assert [target_str, equation_strs] = string.split(line, ": ")
  let assert Ok(target) = int.parse(target_str)
  
  let equations = equation_strs
  |> string.split(" ")
  |> list.map(fn(e_s) {
    let assert Ok(equation) = int.parse(e_s)
    equation
  })
  
  Calibration(target, equations)
}

fn parse_input(input: String) -> List(Calibration) {
  input
  |> string.split("\n")
  |> list.map(parse_line)
}

fn is_possible_helper(target: Int, current: Int, rest: List(Int)) -> Bool {
  use <- bool.guard(list.is_empty(rest), target == current)
  let assert [next, ..rest] = rest
  case int.compare(current, target) {
    order.Gt -> False
    _ -> {
      is_possible_helper(target, next * current, rest) ||
      is_possible_helper(target, next + current, rest)
    }
  }
}

fn is_possible(c: Calibration) -> Bool {
  // TODO this can fail if the line has only one number
  let assert [current, ..rest] = c.equation
  is_possible_helper(c.target, current, rest)
}

pub fn pt_1(input: String) {
  input
  |> parse_input
  |> list.filter(is_possible)
  |> list.map(fn(c) {c.target})
  |> int.sum  
}

pub fn pt_2(input: String) {
  todo as "part 2 not implemented"
}
