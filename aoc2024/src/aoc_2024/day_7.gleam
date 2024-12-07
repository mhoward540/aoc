import gleam/bool
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/order
import gleam/string

type Calibration {
  Calibration(target: Int, equation: List(Int))
}

fn parse_line(line: String) -> Calibration {
  let assert [target_str, equation_strs] = string.split(line, ": ")
  let assert Ok(target) = int.parse(target_str)

  let equations =
    equation_strs
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

type CalibrationOperation {
  Mul
  Add
  Concat
}

fn concat_nums(a: Int, b: Int) -> Int {
  let assert Ok(offset_base) =
    iterator.unfold(1, fn(acc) {
      case acc > b {
        True -> iterator.Done
        False -> iterator.Next(acc, acc * 10)
      }
    })
    |> iterator.last

  { a * offset_base * 10 } + b
}

fn operate(a: Int, b: Int, op: CalibrationOperation) -> Int {
  case op {
    Mul -> a * b
    Add -> a + b
    Concat -> concat_nums(a, b)
  }
}

fn is_possible_helper(
  target: Int,
  current: Int,
  rest: List(Int),
  operations: List(CalibrationOperation),
) -> Bool {
  use <- bool.guard(list.is_empty(rest), target == current)
  let assert [next, ..rest] = rest
  case int.compare(current, target) {
    order.Gt -> False
    _ -> {
      operations
      |> list.map(operate(current, next, _))
      |> list.any(fn(num) { is_possible_helper(target, num, rest, operations) })
    }
  }
}

fn is_possible(c: Calibration, operations: List(CalibrationOperation)) -> Bool {
  // TODO this can fail if the line has only one number
  let assert [current, ..rest] = c.equation
  is_possible_helper(c.target, current, rest, operations)
}

pub fn pt_1(input: String) {
  input
  |> parse_input
  |> list.filter(is_possible(_, [Mul, Add]))
  |> list.map(fn(c) { c.target })
  |> int.sum
}

pub fn pt_2(input: String) {
  input
  |> parse_input
  |> list.filter(is_possible(_, [Mul, Add, Concat]))
  |> list.map(fn(c) { c.target })
  |> int.sum
}
