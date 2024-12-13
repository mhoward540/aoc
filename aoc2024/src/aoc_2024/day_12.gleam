import aoc_util/gridutil.{type Cardinal, type Coord, type GridS}
import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/result
import gleam/set.{type Set}

fn parse_input(input: String) -> GridS {
  input
  |> gridutil.to_grid
}

fn walk_region(
  grid: GridS,
  coord: Coord,
  char: String,
  visited: Set(Coord),
) -> Set(Coord) {
  let assert Ok(curr_char) = dict.get(grid.matrix, coord)
  use <- bool.guard(curr_char != char, visited)

  let visited = set.insert(visited, coord)

  let next_moves =
    coord
    |> gridutil.move_cardinals
    |> list.filter(gridutil.contains(grid, _))
    |> list.filter(fn(x) { !set.contains(visited, x) })

  next_moves
  |> list.fold(visited, fn(v, c) { set.union(v, walk_region(grid, c, char, v)) })
}

fn get_regions(grid: GridS) -> List(Set(Coord)) {
  let visitable =
    dict.keys(grid.matrix)
    |> set.from_list

  iterator.unfold(visitable, fn(vable) {
    use <- bool.guard(set.is_empty(vable), iterator.Done)
    let assert Ok(next_coord) =
      vable
      |> set.to_list
      |> list.first

    let assert Ok(char) = dict.get(grid.matrix, next_coord)

    let region = walk_region(grid, next_coord, char, set.new())

    let vable = set.difference(vable, region)
    iterator.Next(region, vable)
  })
  |> iterator.to_list
}

fn count_exposed_sides(grid: GridS, coord: Coord) -> Int {
  let assert Ok(char) = dict.get(grid.matrix, coord)
  coord
  |> gridutil.move_cardinals
  |> list.filter(fn(c) {
    !gridutil.contains(grid, c)
    || {
      let assert Ok(o_char) = dict.get(grid.matrix, c)
      o_char != char
    }
  })
  |> list.length
}

fn score_region(region: Set(Coord), grid: GridS) -> Int {
  let area = set.size(region)
  let perimeter =
    region
    |> set.to_list
    |> list.map(count_exposed_sides(grid, _))
    |> int.sum

  area * perimeter
}

fn count_vertices(region: Set(Coord)) -> Int {
  region
  |> set.fold(0, fn(v_count, coord) {
    let assert [up, up_right, right, down_right, down, down_left, left, up_left] =
      gridutil.move_card_intercard(coord)
      |> list.map(set.contains(region, _))
      
    let c = [
      !up && !left,
      !up && !right,
      !down && !left,
      !down && !right,
      up && left && !up_left,
      up && right && !up_right,
      down && left && !down_left,
      down && right && !down_right,
    ]
    |> list.count(fn(x) {x}) 
    
    v_count + c
  })
}

fn score_region2(region: Set(Coord)) -> Int {
  let area = set.size(region)
  use <- bool.guard(area == 1, 4)
  let side_count = count_vertices(region)

  side_count * area
}

pub fn pt_1(input: String) {
  let grid =
    input
    |> parse_input

  grid
  |> get_regions
  |> list.map(score_region(_, grid))
  |> int.sum
}

pub fn pt_2(input: String) {
  let grid =
    input
    |> parse_input

  grid
  |> get_regions
  |> list.map(score_region2)
  |> int.sum
}
