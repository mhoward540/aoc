import aoc_util/gridutil.{type Coord, type Grid}
import gleam/bool
import gleam/dict
import gleam/list
import gleam/result
import gleam/yielder

type Space {
  Empty
  Paper
  Movable
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

fn list_movable(grid: Grid(Space), threshold: Int) -> List(List(Coord)) {
  grid
  |> gridutil.iter_grid
  |> yielder.filter(fn(t) { t.1 == Paper })
  |> yielder.map(fn(t) {
    let #(coord, _space) = t
    coord
    |> gridutil.move_card_intercard
    |> list.filter_map(fn(adj_coord) {
      let adj_space = dict.get(grid.matrix, adj_coord)
      use <- bool.guard(result.is_error(adj_space), Error(adj_coord))
      let assert Ok(adj_space) = adj_space

      case adj_space {
        Paper -> Ok(adj_coord)
        _ -> Error(adj_coord)
      }
    })
  })
  |> yielder.filter(fn(adj_coords) { list.length(adj_coords) < threshold })
  |> yielder.to_list
}

pub fn pt_1(input: String) {
  input
  |> parse_input
  |> list_movable(4)
  |> list.length
}

pub fn pt_2(input: String) {
  todo as "part 2 not implemented"
}
