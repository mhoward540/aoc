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

  #(grid, antennas)
}

fn map_antinodes(pair: #(Coord, Coord)) -> Set(Coord) {
  let #(a, b) = pair
  let assert [small, big] =
    [a, b]
    |> list.sort(gridutil.coord_compare)

  let delta = gridutil.sub(big, small)

  [gridutil.sub(small, delta), gridutil.add(big, delta)]
  |> set.from_list
}

// walk coords by step of size delta, until the coord is outside of the grid
fn walk(
  start: Coord,
  delta: Coord,
  visited: Set(Coord),
  in_grid: fn(Coord) -> Bool,
) -> Set(Coord) {
  case in_grid(start) {
    True -> {
      let new_coord = gridutil.add(start, delta)
      let visited = set.insert(visited, start)
      walk(new_coord, delta, visited, in_grid)
    }
    False -> visited
  }
}

fn map_antinode_line(pair: #(Coord, Coord), grid: GridS) -> Set(Coord) {
  let in_grid = fn(c: Coord) { gridutil.contains(grid, c) }

  let #(a, b) = pair
  let assert [small, big] =
    [a, b]
    |> list.sort(gridutil.coord_compare)

  let delta_pos = gridutil.sub(big, small)
  let delta_neg = gridutil.neg(delta_pos)

  set.union(
    walk(small, delta_neg, set.new(), in_grid),
    walk(big, delta_pos, set.new(), in_grid),
  )
}

pub fn pt_1(input: String) {
  let #(grid, antennas) =
    input
    |> parse_input

  let antinodes =
    antennas
    |> dict.values
    |> list.flat_map(fn(coords_for_group) {
      coords_for_group
      |> list.combination_pairs
    })
    |> list.map(map_antinodes)
    |> list.fold(set.new(), set.union)
    |> set.filter(gridutil.contains(grid, _))

  // let drawable =
  //   antinodes
  //   |> set.to_list
  //   |> list.fold(grid.matrix, fn(d, coord) { dict.insert(d, coord, "#") })

  // Grid(drawable, grid.max_y, grid.max_x)
  // |> gridutil.draw_grid

  antinodes
  |> set.size
}

pub fn pt_2(input: String) {
  let #(grid, antennas) =
    input
    |> parse_input

  let antinodes =
    antennas
    |> dict.values
    |> list.flat_map(fn(coords_for_group) {
      coords_for_group
      |> list.combination_pairs
    })
    |> list.map(map_antinode_line(_, grid))
    |> list.fold(set.new(), set.union)

  // let drawable =
  //   antinodes
  //   |> set.to_list
  //   |> list.fold(grid.matrix, fn(d, coord) { dict.insert(d, coord, "#") })

  // Grid(drawable, grid.max_y, grid.max_x)
  // |> gridutil.draw_grid

  antinodes |> set.size
}
