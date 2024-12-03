import gleam/int
import gleam/io
import gleam/list
import gleam/regex
import gleam/string

fn extract(input: String) {
  let assert Ok(p) =
    regex.compile(
      "mul\\(\\d\\d?\\d?,\\d\\d?\\d?\\)",
      regex.Options(case_insensitive: False, multi_line: True),
    )
  let matches = regex.scan(p, input)

  matches
  |> list.map(io.debug)
  |> list.map(fn(match) {
    let assert [left_s, right_s] =
      match.content
      |> string.drop_left(4)
      |> string.drop_right(1)
      |> string.split(",")
      |> io.debug

    let assert Ok(left) = int.parse(left_s)
    let assert Ok(right) = int.parse(right_s)

    #(left, right)
  })
}

pub fn pt_1(input: String) {
  input
  |> extract
  |> list.map(fn(t) { int.multiply(t.0, t.1) })
  |> int.sum
}

pub fn pt_2(input: String) {
  todo as "part 2 not implemented"
}
