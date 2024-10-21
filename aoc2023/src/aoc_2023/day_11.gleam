import gleam/int
import gleam/iterator
import gleam/list
import gleam/string

pub type Coord =
  #(Int, Int)

fn get_expansion_indexes(l: List(List(String))) {
  l
  |> list.index_map(fn(line, index) {
    let res =
      line
      |> list.all(fn(x) { x == "." })

    #(index, res)
  })
  |> list.filter_map(fn(ix_and_res) {
    let #(index, result) = ix_and_res
    case result {
      True -> Ok(index)
      False -> Error(index)
    }
  })
}

fn find_vertical_expansions(lines: List(List(String))) {
  lines
  |> get_expansion_indexes
}

fn get_columns(lines: List(List(String))) -> List(List(String)) {
  let line_len = {
    let assert Ok(line) = list.first(lines)
    list.length(line)
  }

  list.range(0, line_len - 1)
  |> list.map(fn(index) {
    lines
    |> list.map(fn(line) {
      let assert Ok(char_at) = iterator.at(iterator.from_list(line), index)
      char_at
    })
  })
}

fn find_horiz_expansions(lines: List(List(String))) {
  lines
  |> get_columns
  |> get_expansion_indexes
}

fn expand_horiz(
  galaxies: List(Coord),
  indexes: List(Int),
  increment: Int,
) -> List(Coord) {
  let get_smaller_indexes = fn(coord: Coord) {
    indexes
    |> list.filter(fn(index) { index < coord.1 })
  }

  galaxies
  |> list.map(fn(gal_coord) {
    let smaller_indexes = get_smaller_indexes(gal_coord)

    let coord_increase = list.length(smaller_indexes) * { increment - 1 }

    #(gal_coord.0, gal_coord.1 + coord_increase)
  })
}

fn expand_vert(
  galaxies: List(Coord),
  indexes: List(Int),
  increment: Int,
) -> List(Coord) {
  let get_smaller_indexes = fn(coord: Coord) {
    indexes
    |> list.filter(fn(index) { index < coord.0 })
  }

  galaxies
  |> list.map(fn(gal_coord) {
    let smaller_indexes = get_smaller_indexes(gal_coord)

    let coord_increase = list.length(smaller_indexes) * { increment - 1 }

    #(gal_coord.0 + coord_increase, gal_coord.1)
  })
}

fn find_galaxies(lines: List(List(String))) -> List(Coord) {
  lines
  |> list.index_map(fn(line, y) {
    line
    |> list.index_map(fn(char, x) {
      let coord = #(y, x)
      #(coord, char)
    })
  })
  |> list.flatten
  |> list.filter_map(fn(coord_and_char) {
    let #(coord, char) = coord_and_char
    case char {
      "#" -> Ok(coord)
      _ -> Error("")
    }
  })
}

fn parse_input_and_expand(input: String, expansion_size: Int) {
  let split_lines =
    input
    |> string.split("\n")
    |> list.map(fn(line) { string.split(line, "") })

  let vert_expansion_points = find_vertical_expansions(split_lines)

  let horiz_expansion_points = find_horiz_expansions(split_lines)

  let galaxies = find_galaxies(split_lines)

  galaxies
  |> expand_horiz(horiz_expansion_points, expansion_size)
  |> expand_vert(vert_expansion_points, expansion_size)
}

fn get_path_distance(coords: #(Coord, Coord)) -> Int {
  let #(#(y0, x0), #(y1, x1)) = coords

  let y_dist = int.absolute_value(y0 - y1)
  let x_dist = int.absolute_value(x0 - x1)

  x_dist + y_dist
}

pub fn pt_1(input: String) {
  let galaxy_coords =
    input
    |> parse_input_and_expand(2)

  let coord_pairs =
    galaxy_coords
    |> list.combination_pairs

  coord_pairs
  |> list.map(get_path_distance(_))
  |> list.fold(0, int.add)
}

pub fn pt_2(input: String) {
  let galaxy_coords =
    input
    |> parse_input_and_expand(1_000_000)

  let coord_pairs =
    galaxy_coords
    |> list.combination_pairs

  coord_pairs
  |> list.map(get_path_distance(_))
  |> list.fold(0, int.add)
}
