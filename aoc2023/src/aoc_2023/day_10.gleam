import gleam/dict.{type Dict}
import gleam/io
import gleam/list.{Continue, Stop}
import gleam/set.{type Set}
import gleam/string

type Coord =
  #(Int, Int)

fn parse_line(y_coord: Int, line: String) -> List(#(Coord, String)) {
  line
  |> string.split("")
  |> list.index_map(fn(char: String, x_coord: Int) {
    #(#(y_coord, x_coord), char)
  })
}

fn parse_input(input: String) -> #(Coord, Dict(Coord, String)) {
  let coords =
    input
    |> string.split("\n")
    |> list.index_map(fn(a, b) { parse_line(b, a) })
    |> list.flatten

  let assert Ok(#(starting_coords, _)) =
    coords
    |> list.find(fn(coord_and_char) { coord_and_char.1 == "S" })

  #(starting_coords, dict.from_list(coords))
}

fn get_next_search_coords(
  char: String,
  coords: Coord,
  start_coords: Coord,
  visited_coords: Set(Coord),
  coord_map: Dict(Coord, String),
) -> Coord {
  let #(y, x) = coords
  let #(possible_next_1, possible_next_2) = case char {
    "|" -> #(#(y + 1, x), #(y - 1, x))
    "-" -> #(#(y, x + 1), #(y, x - 1))
    "L" -> #(#(y, x + 1), #(y - 1, x))
    "J" -> #(#(y, x - 1), #(y - 1, x))
    "7" -> #(#(y, x - 1), #(y + 1, x))
    "F" -> #(#(y, x + 1), #(y + 1, x))
    _ -> #(#(-1, -1), #(-1, -1))
  }

  let next_char_1 = dict.get(coord_map, possible_next_1)
  let next_char_2 = dict.get(coord_map, possible_next_2)
  let coords_1_were_visited = set.contains(visited_coords, possible_next_1)
  let coords_2_were_visited = set.contains(visited_coords, possible_next_2)
  let coords_1_is_start = possible_next_1 == start_coords
  let coords_2_is_start = possible_next_2 == start_coords

  case
    next_char_1,
    next_char_2,
    coords_1_were_visited,
    coords_2_were_visited,
    coords_1_is_start,
    coords_2_is_start
  {
    // If only one of the coords is in bounds, visit that one next
    Ok(_), Error(_), _, _, _, _ -> possible_next_1
    Error(_), Ok(_), _, _, _, _ -> possible_next_2

    // Get the coords that haven't yet been visited
    _, _, True, False, _, _ -> possible_next_2
    _, _, False, True, _, _ -> possible_next_1

    // if only one of the next coords is the starting coords, then move to the non-starting coords. Avoids backtracking early
    _, _, False, False, True, False -> possible_next_2
    _, _, False, False, False, True -> possible_next_1

    _, _, _, _, _, _ -> {
      // happens at the start case. Just pick one
      io.debug("just picking one :|")
      possible_next_1
    }
  }
}

fn determine_start_coord_shape() -> String {
  // TODO
  "|"
}

// Returns path traversed through map as a list
fn traverse_map(
  curr_coord: Coord,
  curr_depth: Int,
  curr_path: List(Coord),
  start_coord: Coord,
  visited_coords: Set(Coord),
  coord_map: Dict(Coord, String),
) -> List(Coord) {
  let #(next_map, coord_shape) = case curr_depth {
    0 -> {
      let cs = determine_start_coord_shape()
      let m = dict.insert(coord_map, curr_coord, cs)
      #(m, cs)
    }
    _ -> {
      let assert Ok(s) = dict.get(coord_map, curr_coord)
      #(coord_map, s)
    }
  }

  // io.debug(coord_shape)

  let #(new_visited, new_path) = case curr_depth {
    0 -> #(visited_coords, curr_path)
    _ -> {
      #(set.insert(visited_coords, curr_coord), [curr_coord, ..curr_path])
    }
  }

  case curr_coord {
    x if x == start_coord && curr_depth != 0 -> new_path
    _ -> {
      let next_coords =
        get_next_search_coords(
          coord_shape,
          curr_coord,
          start_coord,
          new_visited,
          next_map,
        )

      traverse_map(
        next_coords,
        curr_depth + 1,
        new_path,
        start_coord,
        new_visited,
        next_map,
      )
    }
  }
}

pub fn pt_1(input: String) {
  let #(start_coord, coord_map) =
    input
    |> parse_input

  let path_traveled =
    traverse_map(start_coord, 0, [], start_coord, set.new(), coord_map)
  // |> io.debug

  path_traveled
  |> list.map(fn(coord) {
    let assert Ok(char) = dict.get(coord_map, coord)
    char
  })
  // |> io.debug

  list.length(path_traveled) / 2
}

pub fn pt_2(input: String) {
  let #(start_coord, coord_map) =
    input
    |> parse_input

  let path_traveled =
    traverse_map(start_coord, 0, [], start_coord, set.new(), coord_map)
  // |> io.debug

  path_traveled
  |> list.map(fn(coord) {
    let assert Ok(char) = dict.get(coord_map, coord)
    char
  })
  // |> io.debug

  list.length(path_traveled) / 2
}
