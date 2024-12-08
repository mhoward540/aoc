import aoc_util/gridutil.{type Coord, type GridS, Grid}
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/set.{type Set}

// Antenna character mapped to all locations for that character
type AntennaDict =
  Dict(String, List(Coord))

fn parse_input(input: String) -> #(GridS, AntennaDict) {
  let grid =
    input
    |> gridutil.to_grid

  let antennas =
    grid.matrix
    |> dict.to_list
    |> list.group(fn(item) { item.1 })
    |> dict.delete(".")
    |> dict.map_values(fn(_k, v) {
      v
      |> list.map(fn(x) { x.0 })
    })
  // |> io.debug

  #(grid, antennas)
}


fn map_antinodes(entry: #(String, List(Coord))) {
  let #(char, coords) = entry

  let out =
    coords
    |> list.combination_pairs
    |> list.map(fn(e) {
      let #(a, b) = e
      let assert [small, big] =
        [a, b]
        |> list.sort(gridutil.coord_compare)

      let y_diff = big.0 - small.0
      let x_diff = big.1 - small.1

      [#(small.0 - y_diff, small.1 - x_diff), #(big.0 + y_diff, big.1 + x_diff)]
    })
    |> list.flatten

  // io.debug(char)
  // io.debug(a)
  // io.debug("")
  out
}

fn walk(start: Coord, delta: Coord, visited: Set(Coord), in_grid: fn (Coord) -> Bool) -> Set(Coord) {
  let #(y_s, x_s) = start
  let #(y_d, x_d) = delta
  case in_grid(start) {
    True -> {
      let new_coord = #(y_s + y_d, x_s + x_d)
      let visited = set.insert(visited, start)
      walk(new_coord, delta, visited, in_grid)
    }
    False -> visited
  }
}

fn map_antinodes2(entry: #(String, List(Coord)), grid: GridS) {
  let #(char, coords) = entry
  
  let in_grid = fn(c: Coord) {
    let #(y, x) = c
    y >= 0
    && x >= 0
    && y <= grid.max_y
    && x <= grid.max_x
  }

  let out =
    coords
    |> list.combination_pairs
    |> list.map(fn(e) {
      let #(a, b) = e
      let assert [small, big] =
        [a, b]
        |> list.sort(gridutil.coord_compare)

      let y_diff = big.0 - small.0
      let x_diff = big.1 - small.1
      
      let delta_pos = #(y_diff, x_diff)
      let delta_neg = #(-y_diff, -x_diff)
      
      set.union(
        walk(small, delta_neg, set.new(), in_grid),
        walk(big, delta_pos, set.new(), in_grid)
      )
    })
    |> list.fold(set.new(), set.union)

  // io.debug(char)
  // io.debug(a)
  // io.debug("")
  out
}

pub fn pt_1(input: String) {
  let #(grid, antennas) =
    input
    |> parse_input

  let antinodes =
    antennas
    |> dict.to_list
    |> list.map(map_antinodes(_))
    |> list.flatten
    |> list.unique
    |> list.filter(fn(coord) {
      let #(y, x) = coord
      y >= 0
      && x >= 0
      && y <= grid.max_y
      && x <= grid.max_x
    })
    |> list.unique

  // let drawable =
  //   antinodes
  //   |> list.fold(grid.matrix, fn(d, coord) { dict.insert(d, coord, "#") })

  // Grid(drawable, grid.max_y, grid.max_x)
  // |> gridutil.draw_grid

  antinodes
  |> list.length
}

pub fn pt_2(input: String) {
  let #(grid, antennas) =
    input
    |> parse_input

  let antinodes =
    antennas
    |> dict.to_list
    |> list.map(map_antinodes2(_, grid))
    |> list.fold(set.new(), set.union)
    
  // let drawable =
  //   antinodes
  //   |> set.to_list
  //   |> list.fold(grid.matrix, fn(d, coord) { dict.insert(d, coord, "#") })

  // Grid(drawable, grid.max_y, grid.max_x)
  // |> gridutil.draw_grid
  
  antinodes |> set.size
}
