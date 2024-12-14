import aoc_util/gridutil.{type Coord, type Grid}
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/option
import gleam/order
import gleam/regex
import gleam/result
import gleam/set.{type Set}
import gleam/string

type Position {
  Position(x: Int, y: Int)
}

type Velocity {
  Velocity(x: Int, y: Int)
}

type Robot =
  #(Position, Velocity)

fn parse_input(input: String) -> List(Robot) {
  let assert Ok(re) =
    regex.compile(
      "p=(-?\\d+),(-?\\d+) v=(-?\\d+),(-?\\d+)",
      regex.Options(case_insensitive: False, multi_line: False),
    )
  let lines = string.split(input, "\n")
  use line <- list.map(lines)
  let assert Ok(match) =
    regex.scan(re, line)
    |> list.first

  let assert [pos_x, pos_y, v_x, v_y] =
    match.submatches
    |> list.map(option.lazy_unwrap(_, fn() {
      panic as "regex match is goofed up"
    }))
    |> list.map(int.parse)
    |> result.values

  #(Position(pos_x, pos_y), Velocity(v_x, v_y))
}

fn simulate_movement(
  r: Robot,
  seconds: Int,
  width: Int,
  height: Int,
) -> Position {
  let #(pos, vel) = r
  let #(px, py) = #(pos.x, pos.y)
  let #(vx, vy) = #(vel.x, vel.y)

  let new_px = { px + { seconds * vx } } % width
  let new_px = case new_px < 0 {
    True -> width + new_px
    False -> new_px
  }

  let new_py = { py + { seconds * vy } } % height
  let new_py = case new_py < 0 {
    True -> height + new_py
    False -> new_py
  }

  Position(new_px, new_py)
}

fn qualify_quadrant(p: Position, width: Int, height: Int) -> Int {
  let half_width = width / 2
  let half_height = height / 2

  case int.compare(p.x, half_width), int.compare(p.y, half_height) {
    order.Eq, _ | _, order.Eq -> 0
    order.Lt, order.Lt -> 1
    order.Lt, order.Gt -> 2
    order.Gt, order.Lt -> 3
    order.Gt, order.Gt -> 4
  }
}

fn safety_factor(positions: List(Position), width: Int, height: Int) -> Int {
  let #(q1, q2, q3, q4) =
    positions
    |> list.map(fn(pos) { #(pos, qualify_quadrant(pos, width, height)) })
    |> list.filter(fn(t) { t.1 > 0 })
    |> list.fold(#(0, 0, 0, 0), fn(acc, t) {
      case t.1 {
        1 -> #(acc.0 + 1, acc.1, acc.2, acc.3)
        2 -> #(acc.0, acc.1 + 1, acc.2, acc.3)
        3 -> #(acc.0, acc.1, acc.2 + 1, acc.3)
        4 -> #(acc.0, acc.1, acc.2, acc.3 + 1)
        _ -> panic as "sike, thats the wrong number"
      }
    })

  q1 * q2 * q3 * q4
}

pub fn pt_1(input: String) {
  let width = 101
  let height = 103

  input
  |> parse_input
  |> list.map(simulate_movement(_, 100, width, height))
  |> safety_factor(width, height)
}

fn print_grid(
  positions: List(Position),
  width: Int,
  height: Int,
) -> List(Position) {
  let d =
    {
      use y <- iterator.map(iterator.range(0, height - 1))
      use x <- iterator.map(iterator.range(0, width - 1))
      #(#(y, x), ".")
    }
    |> iterator.flatten
    |> iterator.to_list
    |> dict.from_list

  let d =
    positions
    |> list.fold(d, fn(acc, p) {
      let coord = #(p.y, p.x)
      dict.insert(acc, coord, "#")
    })

  gridutil.Grid(matrix: d, max_y: height - 1, max_x: width - 1)
  |> gridutil.draw_grid

  positions
}

fn detect_cycle(
  slow_depth: Int,
  fast_depth: Int,
  initstate: List(#(Position, Velocity)),
  width: Int,
  height: Int,
  cache: Dict(Int, List(Position)),
) -> Int {
  let slow_pos =
    result.lazy_unwrap(dict.get(cache, slow_depth), fn() {
      initstate
      |> list.map(simulate_movement(_, slow_depth, width, height))
    })

  let fast_pos =
    result.lazy_unwrap(dict.get(cache, fast_depth), fn() {
      initstate
      |> list.map(simulate_movement(_, fast_depth, width, height))
    })

  let cache =
    cache
    |> dict.insert(slow_depth, slow_pos)
    |> dict.insert(fast_depth, fast_pos)

  case slow_pos == fast_pos {
    False ->
      detect_cycle(
        slow_depth + 1,
        fast_depth + 2,
        initstate,
        width,
        height,
        cache,
      )
    True -> slow_depth
  }
}

pub fn pt_2(input: String) {
  let width = 101
  let height = 103

  let initstate =
    input
    |> parse_input

  let max_range = detect_cycle(0, 2, initstate, width, height, dict.new())

  let assert Ok(state_with_min_safety) =
    list.range(0, max_range)
    |> list.map(fn(num) {
      let state =
        initstate
        |> list.map(simulate_movement(_, num, width, height))

      #(safety_factor(state, width, height), num, state)
    })
    |> list.sort(fn(a, b) { int.compare(a.0, b.0) })
    |> list.first

  print_grid(state_with_min_safety.2, width, height)

  state_with_min_safety.1
}
