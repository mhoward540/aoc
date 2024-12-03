import gleam/int
import gleam/io
import gleam/list
import gleam/regex
import gleam/string

type Instruction {
  Mul(left: Int, right: Int)
  Do
  Dont
}

fn extract_instruction(instruction: String) {
  let assert [instruction, rest] = string.split(instruction, "(")
  case instruction {
    "do" -> Do
    "don't" -> Dont
    "mul" -> {
      let assert [left_s, right_s] =
        rest
        |> string.drop_right(1)
        |> string.split(",")

      let assert Ok(left) = int.parse(left_s)
      let assert Ok(right) = int.parse(right_s)

      Mul(left, right)
    }
    _ -> panic as "Could not parse instruction"
  }
}

fn extract(input: String) {
  let assert Ok(p) =
    regex.compile(
      "(mul\\(\\d\\d?\\d?,\\d\\d?\\d?\\))|(do\\(\\))|(don\\'t\\(\\))",
      regex.Options(case_insensitive: False, multi_line: True),
    )

  let matches = regex.scan(p, input)

  matches
  |> list.map(fn(match) { extract_instruction(match.content) })
}

fn follow_instructions(instructions: List(Instruction)) -> Int {
  let #(_, l) =
    instructions
    |> list.fold(#(True, []), fn(acc, inst) {
      let #(can_run, curr_list) = acc

      case inst, can_run {
        Do, _ -> #(True, curr_list)
        Dont, _ -> #(False, curr_list)
        Mul(_, _), False -> #(False, curr_list)
        Mul(a, b), True -> {
          #(True, [#(a, b), ..curr_list])
        }
      }
    })

  l
  |> list.map(fn(t) { int.multiply(t.0, t.1) })
  |> int.sum
}

pub fn pt_1(input: String) {
  input
  |> extract
  |> list.map(fn(inst) {
    case inst {
      Mul(a, b) -> #(a, b)
      _ -> #(0, 0)
    }
  })
  |> list.map(fn(t) { int.multiply(t.0, t.1) })
  |> int.sum
}

pub fn pt_2(input: String) {
  input
  |> extract
  |> follow_instructions
}
