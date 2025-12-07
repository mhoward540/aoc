import aoc_util/gridutil.{type Coord, type Grid}
import gleam/bool
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/set.{type Set}
import gleam/string

type Space {
  Start
  Empty
  Yon
  Visited
}

fn parse_input(input: String) -> #(Grid(Space), Coord) {
  let m =
    input
    |> gridutil.to_grid_transform(fn(char) {
      case char {
        "S" -> Start
        "." -> Empty
        "^" -> Yon
        _ -> panic as "Unrecognized Space"
      }
    })

  let assert Ok(start) =
    list.range(0, m.max_x)
    |> list.filter_map(fn(x) {
      let c = #(0, x)
      let s = dict.get(m.matrix, c)
      case s {
        Ok(_) -> Ok(#(c, s))
        Error(_) -> Error("")
      }
    })
    |> list.filter(fn(t) { t.1 == Ok(Start) })
    |> list.first

  #(m, start.0)
}

fn split_beams(
  grid: Grid(Space),
  to_visit: List(Coord),
  visited: Set(Coord),
  split_count: Int,
) {
  let #(next, new_splits) =
    to_visit
    |> list.filter_map(fn(coord) {
      case dict.get(grid.matrix, coord) {
        Ok(s) -> Ok(#(coord, s))
        _ -> Error("")
      }
    })
    |> list.filter(fn(t) { !set.contains(visited, t.0) })
    |> list.fold(#([], 0), fn(acc, t) {
      let #(next_visit, curr_count) = acc
      let #(coord, space) = t
      case space {
        Empty | Start -> #([gridutil.down(coord), ..next_visit], curr_count)
        Yon -> {
          let l = gridutil.left(coord)
          let r = gridutil.right(coord)
          #([l, r, ..next_visit], curr_count + 1)
        }
        _ -> panic as "again unrecognized"
      }
    })

  let visited =
    to_visit
    |> set.from_list
    |> set.union(visited)

  //dedupe - maybe `next` should be a set
  let next =
    next
    |> set.from_list
    |> set.to_list

  echo #(split_count, new_splits)
  use <- bool.guard(list.is_empty(next), #(split_count + new_splits, visited))

  split_beams(grid, next, visited, split_count + new_splits)
}

pub fn pt_1(input: String) {
  let #(grid, start) =
    input
    |> parse_input

  let #(count, visited) = split_beams(grid, [start], set.new(), 0)

  let drawable =
    visited
    |> set.to_list
    |> list.fold(grid, fn(g, coord) {
      case gridutil.contains(g, coord) {
        True -> gridutil.insert(g, coord, Visited)
        False -> g
      }
    })

  let ascii =
    drawable
    |> gridutil.stringify_grid_transform(fn(space) {
      case space {
        Start -> "S"
        Empty -> "."
        Visited -> "|"
        Yon -> "^"
      }
    })

  io.println(ascii)

  count
}

pub fn pt_2(input: String) {
  let lines =
    input
    |> string.split("\n")

  let yons =
    lines
    |> list.map(string.to_graphemes)
    |> list.map(fn(line) {
      line
      |> list.index_map(fn(c, i) { #(i, c) })
      |> list.filter_map(fn(t) {
        case t.1 {
          "^" -> Ok(t.0)
          _ -> Error("")
        }
      })
    })

  let assert [#(start, _)] =
    input
    |> string.to_graphemes
    |> list.index_map(fn(c, i) { #(i, c) })
    |> list.filter(fn(c) { c.1 == "S" })

  let d = [#(start, 1)] |> dict.from_list

  yons
  |> list.fold(d, fn(d, line) {
    let split_beams =
      d
      |> dict.keys()
      |> set.from_list
      |> set.intersection(set.from_list(line))
      |> set.to_list

    let new_d = d
    split_beams
    |> list.fold(new_d, fn(new_d, beam) {
      let assert Ok(val) = dict.get(d, beam)

      new_d
      |> dict.delete(beam)
      |> dict.upsert(beam - 1, fn(res) {
        case res {
          option.Some(vv) -> val + vv
          option.None -> val
        }
      })
      |> dict.upsert(beam + 1, fn(res) {
        case res {
          option.Some(vv) -> val + vv
          option.None -> val
        }
      })
    })
  })
  |> dict.values
  |> int.sum
}
