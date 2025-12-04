import aoc_util/gridutil.{type Coord, type Grid}
import gleam/bool
import gleam/dict
import gleam/list
import gleam/result
import gleam/yielder

type Space {
  Empty
  Paper
}

fn parse_input(input: String) -> Grid(Space) {
  input
  |> gridutil.to_grid_transform(fn(s) {
    case s {
      "@" -> Paper
      "." -> Empty
      _ -> panic as "Unrecognized Space"
    }
  })
}

fn list_adjacent_paper(grid: Grid(Space), coord: Coord) {
  coord
  |> gridutil.move_card_intercard
  |> list.filter_map(fn(adj_coord) {
    let adj_space = dict.get(grid.matrix, adj_coord)

    case adj_space {
      Ok(Paper) -> Ok(adj_coord)
      _ -> Error(adj_coord)
    }
  })
}

fn list_movable(grid: Grid(Space), threshold: Int) -> List(Coord) {
  grid
  |> gridutil.iter_grid
  |> yielder.filter(fn(t) { t.1 == Paper })
  |> yielder.map(fn(t) {
    let #(coord, _space) = t
    let adjacents = list_adjacent_paper(grid, coord)
    #(coord, adjacents)
  })
  |> yielder.filter(fn(t) { list.length(t.1) < threshold })
  |> yielder.map(fn(t) { t.0 })
  |> yielder.to_list
}

fn repeatedly_move(
  grid: Grid(Space),
  curr_movable: List(List(Coord)),
) -> List(Coord) {
  let movable =
    grid
    |> list_movable(4)

  use <- bool.guard(list.is_empty(movable), curr_movable |> list.flatten)
  let new_grid =
    movable
    |> list.fold(grid, fn(g, m_coord) { gridutil.insert(g, m_coord, Empty) })

  let curr_movable = [movable, ..curr_movable]

  repeatedly_move(new_grid, curr_movable)
}

pub fn pt_1(input: String) {
  input
  |> parse_input
  |> list_movable(4)
  |> list.length
}

pub fn pt_2(input: String) {
  input
  |> parse_input
  |> repeatedly_move([])
  |> list.length
}
