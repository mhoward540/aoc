import gleam/dict
import gleam/int
import gleam/list
import gleam/result
import gleam/string

const specials: List(String) = [
  "+", "@", "$", "-", "%", "/", "&", "*", "#", "=",
]

const numbers: List(String) = [
  "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0",
]

fn coords_for_chars(y_coord: Int, line: List(String)) {
  line
  |> list.index_map(fn(char: String, x_coord: Int) {
    #(#(y_coord, x_coord), char)
  })
}

fn find_digits_at_coord(
  coords: #(Int, Int),
  orig_map: dict.Dict(#(Int, Int), String),
  step: Int,
  curr_digits: List(#(Int, String)),
) -> List(#(Int, String)) {
  let #(y_coord, x_coord) = coords
  let char = dict.get(orig_map, coords)
  let is_num = fn(c: Result(String, Nil)) {
    let thing = result.unwrap(c, "-1")
    list.contains(numbers, thing)
  }
  let char_is_num = is_num(char)

  case char {
    Ok(x) if char_is_num ->
      find_digits_at_coord(#(y_coord, x_coord + step), orig_map, step, [
        #(x_coord, x),
        ..curr_digits
      ])
    _ -> curr_digits
  }
}

fn find_num_at_coord(
  coords: #(Int, Int),
  orig_map: dict.Dict(#(Int, Int), String),
) -> Result(Int, Nil) {
  // Grow outward in both x directions to grab all digits 
  // Since we are keeping track of their indices we can easily filter duplicate digits
  let left_digits = find_digits_at_coord(coords, orig_map, -1, [])
  let right_digits = find_digits_at_coord(coords, orig_map, 1, [])
  let digits = list.concat([left_digits, right_digits])

  digits
  |> list.unique
  // Sorting by x coord to ensure all digits are in the proper place
  |> list.sort(fn(a, b) { int.compare(a.0, b.0) })
  |> list.map(fn(x) { x.1 })
  |> string.join("")
  |> int.parse
}

fn find_adjacent_nums(
  coords: #(Int, Int),
  orig_map: dict.Dict(#(Int, Int), String),
) -> List(Int) {
  let #(y_coord, x_coord) = coords
  // Visit all the coordinates adjacent to `coords` and parse the number there (or return an error)
  [
    #(y_coord - 1, x_coord),
    #(y_coord + 1, x_coord),
    #(y_coord, x_coord - 1),
    #(y_coord, x_coord + 1),
    #(y_coord + 1, x_coord + 1),
    #(y_coord - 1, x_coord + 1),
    #(y_coord + 1, x_coord - 1),
    #(y_coord - 1, x_coord - 1),
  ]
  |> list.map(fn(coord) { find_num_at_coord(coord, orig_map) })
  |> list.filter_map(fn(x) { x })
  // TODO this is a hack - it doesn't handle the case where 2 numbers of the exact same value are adjacent to the same symbol
  |> list.unique
}

fn find_nums_adjacent_to_specials(
  coords: #(Int, Int),
  orig_map: dict.Dict(#(Int, Int), String),
  symbols: List(String),
) {
  let char =
    dict.get(orig_map, coords)
    // Should never happen that `get` fails here
    |> result.unwrap(".")

  let is_num = list.contains(numbers, char)
  let is_special = list.contains(symbols, char)
  case char {
    "." -> []
    _x if is_num -> []
    _x if is_special -> find_adjacent_nums(coords, orig_map)
    _ -> []
  }
}

fn input_to_coord_map(input: String) {
  let lines =
    input
    |> string.split(on: "\n")

  let str_matrix =
    lines
    |> list.map(fn(line: String) { string.split(line, on: "") })

  str_matrix
  |> list.index_map(fn(a, b) { coords_for_chars(b, a) })
  |> list.flatten
  |> dict.from_list
}

pub fn pt_1(input: String) {
  let coords_to_char = input_to_coord_map(input)

  let find_adjacent_part_1 = find_nums_adjacent_to_specials(
    _,
    coords_to_char,
    specials,
  )

  coords_to_char
  |> dict.keys
  |> list.map(find_adjacent_part_1)
  |> list.flatten
  |> list.fold(0, int.add)
}

fn mult(a: Int, b: Int) {
  a * b
}

pub fn pt_2(input: String) {
  let coords_to_char = input_to_coord_map(input)

  let find_adjacent_part_2 = find_nums_adjacent_to_specials(
    _,
    coords_to_char,
    ["*"],
  )

  coords_to_char
  |> dict.keys
  |> list.map(find_adjacent_part_2)
  |> list.filter(fn(adjacents) {
    case list.length(adjacents) {
      2 -> True
      _ -> False
    }
  })
  |> list.map(fn(adjacents_list_size_two) {
    list.fold(adjacents_list_size_two, 1, mult)
  })
  |> list.fold(0, int.add)
}
