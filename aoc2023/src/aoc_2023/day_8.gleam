import gleam/dict.{type Dict}
import gleam/iterator
import gleam/list.{Continue, Stop}
import gleam/string

type LeftRightMapping =
  #(String, String)

fn parse_mapping_line(line: String) {
  let assert [key, lr_values] =
    line
    |> string.split(on: " = ")

  let assert [left, right] =
    lr_values
    |> string.replace(each: "(", with: "")
    |> string.replace(each: ")", with: "")
    |> string.split(on: ", ")

  #(key, #(left, right))
}

fn parse_input(input: String) -> #(List(String), Dict(String, LeftRightMapping)) {
  let assert [instructions_str, mapping_str] = string.split(input, on: "\n\n")

  let mapping =
    mapping_str
    |> string.split(on: "\n")
    |> list.map(parse_mapping_line)
    |> dict.from_list

  let instructions = string.split(instructions_str, on: "")

  #(instructions, mapping)
}

fn found_ending_part_1(curr_key: String) {
  curr_key == "ZZZ"
}

fn found_ending_part_2(curr_key: String) {
  string.ends_with(curr_key, "Z")
}

fn follow_mapping(
  starting_key: String,
  instructions: List(String),
  lr_mapping: Dict(String, LeftRightMapping),
  found_ending: fn(String) -> Bool,
) -> #(Int, String) {
  instructions
  |> iterator.from_list
  |> iterator.cycle
  |> iterator.fold_until(#(0, starting_key), fn(acc_tup, curr_instruction) {
    let #(count, curr_key) = acc_tup
    let assert Ok(#(left, right)) = dict.get(lr_mapping, curr_key)
    let next_key = case curr_instruction {
      "L" -> left
      "R" -> right
      _ -> todo
    }

    case found_ending(next_key) {
      True -> Stop(#(count + 1, next_key))
      False -> Continue(#(count + 1, next_key))
    }
  })
}

fn get_starting_keys(lr_mapping: Dict(String, LeftRightMapping)) {
  lr_mapping
  |> dict.keys
  |> list.filter(string.ends_with(_, "A"))
}

fn gcd(a: Int, b: Int) {
  case a, b {
    _, 0 -> a
    _, _ -> gcd(b, a % b)
  }
}

fn lcm(nums: List(Int)) {
  let assert [start, ..rest] = nums

  rest
  |> list.fold(start, fn(acc, curr_num_to_factor) {
    { curr_num_to_factor * acc } / { gcd(curr_num_to_factor, acc) }
  })
}

pub fn pt_1(input: String) {
  let #(instructions, mapping) =
    input
    |> parse_input

  let #(num_steps, _last_key) =
    follow_mapping("AAA", instructions, mapping, found_ending_part_1)

  num_steps
}

pub fn pt_2(input: String) {
  let #(instructions, mapping) =
    input
    |> parse_input

  // Follow mapping for each starting index. They will all sync up when they hit the lcm of all ending indexes
  get_starting_keys(mapping)
  |> list.map(follow_mapping(_, instructions, mapping, found_ending_part_2))
  |> list.map(fn(x) { x.0 })
  |> lcm
}
