import gleam/int
import gleam/io
import gleam/list
import gleam/string

pub type Direction {
  Up
  Down
  Left
  Right
}

pub type Instruction {
  Instruction(direction: Direction, distance: Int)
}

pub type Coord =
  #(Int, Int)

fn parse_direction(s: String) {
  case s {
    "U" -> Up
    "D" -> Down
    "L" -> Left
    "R" -> Right
    other -> panic as { "couldn't parse direction: " <> other }
  }
}

fn parse_direction_int(i: Int) {
  case i {
    0 -> Right
    1 -> Down
    2 -> Left
    3 -> Up
    other ->
      panic as { "couldn't parse int direction: " <> int.to_string(other) }
  }
}

fn parse_input1(input: String) -> List(Instruction) {
  input
  |> string.split("\n")
  |> list.map(fn(line) {
    let assert [dir_str, dist_raw, _color] = string.split(line, " ")

    let assert Ok(dist) = int.parse(dist_raw)
    let dir = parse_direction(dir_str)

    Instruction(dir, dist)
  })
}

fn parse_hex_instruction(hex: String) -> Instruction {
  let hex_dist_raw =
    hex
    |> string.slice(0, 5)

  let direction_raw = string.slice(hex, 5, 1)

  let assert Ok(dist) = int.base_parse(hex_dist_raw, 16)
  let assert Ok(direction_num) = int.parse(direction_raw)
  let direction = parse_direction_int(direction_num)

  Instruction(direction, dist)
}

fn parse_input2(input: String) -> List(Instruction) {
  input
  |> string.split("\n")
  |> list.map(fn(line) {
    let assert [_dir_str, _dist_raw, color] = string.split(line, " ")
    let color =
      color
      |> string.drop_left(2)
      |> string.drop_right(1)

    parse_hex_instruction(color)
  })
}

fn get_diff_from_instrution(inst: Instruction) -> Coord {
  case inst {
    Instruction(Up, ds) -> #(-1 * ds, 0)
    Instruction(Down, ds) -> #(ds, 0)
    Instruction(Left, ds) -> #(0, ds * -1)
    Instruction(Right, ds) -> #(0, ds)
  }
}

fn add_coords(a: Coord, b: Coord) -> Coord {
  #(a.0 + b.0, a.1 + b.1)
}

fn follow_instructions(instructions: List(Instruction)) {
  let #(s, _, _) =
    instructions
    |> list.fold(#(0, 0, 0), fn(acc, instruction) {
      let #(curr_sum, curr_y, curr_x) = acc
      let #(dy, dx) =
        instruction
        |> get_diff_from_instrution
        |> add_coords(#(curr_y, curr_x))

      let new_sum =
        { { curr_x * dy } - { curr_y * dx } } + instruction.distance + curr_sum

      #(new_sum, dy, dx)
    })

  let assert Ok(res) = int.floor_divide(s, 2)
  res + 1
}

pub fn pt_1(input: String) {
  input
  |> parse_input1
  |> follow_instructions
}

pub fn pt_2(input: String) {
  input
  |> parse_input2
  |> follow_instructions
}
