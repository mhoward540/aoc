import aoc_util/gridutil.{type Cardinal, type Coord, type Grid}
import gleam/bool
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/string

type Space {
  Robot
  Box
  Wall
  Empty
  BoxL
  BoxR
}

fn parse_grid(input: String) -> #(Grid(Space), Coord) {
  let grid =
    input
    |> gridutil.to_grid_transform(fn(char) {
      case char {
        "#" -> Wall
        "." -> Empty
        "O" -> Box
        "@" -> Robot
        "[" -> BoxL
        "]" -> BoxR
        _ -> panic as "unrecognized character when parsing grid"
      }
    })

  let assert Ok(robot_location) =
    grid.matrix
    |> dict.to_list
    |> list.filter(fn(entry) {
      case entry.1 {
        Robot -> True
        _ -> False
      }
    })
    |> list.first

  #(grid, robot_location.0)
}

fn parse_moves(input: String) -> List(Cardinal) {
  input
  |> string.split("\n")
  |> list.flat_map(fn(line) {
    line
    |> string.split("")
    |> list.map(fn(char) {
      case char {
        "^" -> gridutil.Up
        "v" -> gridutil.Down
        "<" -> gridutil.Left
        ">" -> gridutil.Right
        _ -> panic as "unrecognized character when parsing moves"
      }
    })
  })
}

fn parse_input(input: String) -> #(Grid(Space), Coord, List(Cardinal)) {
  let assert [grid_s, moves_s] = string.split(input, "\n\n")
  let #(grid, robot_pos) = parse_grid(grid_s)
  let moves = parse_moves(moves_s)

  #(grid, robot_pos, moves)
}

fn scale_grid_input(input: String) -> String {
  input
  |> string.split("\n")
  |> list.map(fn(line) {
    line
    |> string.split("")
    |> list.map(fn(char) {
      case char {
        "#" -> "##"
        "." -> ".."
        "O" -> "[]"
        "@" -> "@."
        _ -> panic as "unrecognized character when scaling grid"
      }
    })
    |> string.join("")
  })
  |> string.join("\n")
}

fn parse_input2(input: String) -> #(Grid(Space), Coord, List(Cardinal)) {
  let assert [grid_s, moves_s] = string.split(input, "\n\n")
  let grid_s = scale_grid_input(grid_s)
  let #(grid, robot_pos) = parse_grid(grid_s)
  let moves = parse_moves(moves_s)

  #(grid, robot_pos, moves)
}

fn scaled_coords(next_coord: Coord, next_space: Space, move: gridutil.Cardinal) {
  case next_space, move {
    BoxL, gridutil.Up | BoxL, gridutil.Down -> #(next_coord, #(
      next_coord.0,
      next_coord.1 + 1,
    ))
    BoxR, gridutil.Up | BoxR, gridutil.Down -> #(
      #(next_coord.0, next_coord.1 - 1),
      next_coord,
    )
    _, _ -> panic as "should not get here"
  }
}

fn do_move(
  curr_pos: Coord,
  curr_space: Space,
  move: Cardinal,
  grid: Grid(Space),
) -> #(Coord, Grid(Space), Bool) {
  let next_coord = gridutil.move(curr_pos, move)
  let assert Ok(next_space) = dict.get(grid.matrix, next_coord)
  case next_space, move {
    Empty, _ -> {
      let grid =
        grid
        |> gridutil.insert(next_coord, curr_space)
        |> gridutil.insert(curr_pos, Empty)

      #(next_coord, grid, True)
    }
    Wall, _ -> #(curr_pos, grid, False)
    Box, _
    | BoxL, gridutil.Left
    | BoxL, gridutil.Right
    | BoxR, gridutil.Right
    | BoxR, gridutil.Left
    -> {
      let #(_, grid, success) = do_move(next_coord, next_space, move, grid)
      case success {
        True -> do_move(curr_pos, curr_space, move, grid)
        False -> #(curr_pos, grid, False)
      }
    }

    BoxL, gridutil.Up
    | BoxL, gridutil.Down
    | BoxR, gridutil.Up
    | BoxR, gridutil.Down
    -> {
      let #(l_coord, r_coord) = scaled_coords(next_coord, next_space, move)
      let #(_, upd_grid, success1) = do_move(l_coord, BoxL, move, grid)
      let #(_, upd_grid, success2) = do_move(r_coord, BoxR, move, upd_grid)
      case success1 && success2 {
        True -> do_move(curr_pos, curr_space, move, upd_grid)
        False -> #(curr_pos, grid, False)
      }
    }

    _, _ -> panic as "found unexpected space when attempting to move"
  }
}

fn predict_movements(
  robot_pos: Coord,
  grid: Grid(Space),
  moves: List(Cardinal),
) -> Grid(Space) {
  use <- bool.guard(list.is_empty(moves), grid)
  let assert [move, ..moves] = moves
  let #(robot_pos, grid, _) = do_move(robot_pos, Robot, move, grid)
  // draw_grid(grid)
  predict_movements(robot_pos, grid, moves)
}

fn draw_grid(grid: Grid(Space)) {
  gridutil.draw_grid_transform(grid, fn(space) {
    case space {
      Wall -> "#"
      Empty -> "."
      Box -> "O"
      Robot -> "@"
      BoxL -> "["
      BoxR -> "]"
    }
  })
}

fn score_grid(grid: Grid(Space), space: Space) -> Int {
  grid.matrix
  |> dict.to_list
  |> list.filter(fn(t) { t.1 == space })
  |> list.map(fn(t) {
    let #(coord, _) = t
    { coord.0 * 100 } + coord.1
  })
  |> int.sum
}


pub fn pt_1(input: String) {
  let #(grid, robot_pos, moves) =
    input
    |> parse_input

  predict_movements(robot_pos, grid, moves)
  // |> draw_grid
  |> score_grid(Box)
}

pub fn pt_2(input: String) {
  let #(grid, robot_pos, moves) =
    input
    |> parse_input2

  predict_movements(robot_pos, grid, moves)
  // |> draw_grid
  |> score_grid(BoxL)
}
