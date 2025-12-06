import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/set.{type Set}
import gleam/string
import gleam/string_tree.{type StringTree}
import gleam/yielder

pub fn all_indices_of(thing: s, l: List(s)) -> List(Int) {
  l
  |> list.index_fold([], fn(acc, item, i) {
    case thing == item {
      True -> [i, ..acc]
      False -> acc
    }
  })
}

pub fn group_maintaining_order(l: List(#(kt, vt))) -> Dict(kt, List(vt)) {
  l
  |> list.fold(dict.new(), fn(acc, t) {
    let #(i, s) = t
    case dict.get(acc, i) {
      Ok(l) -> dict.insert(acc, i, [s, ..l])
      Error(_) -> dict.insert(acc, i, [s])
    }
  })
  |> dict.map_values(fn(_k, v) { v |> list.reverse })
}

pub fn cols(arr: List(List(t))) -> List(List(t)) {
  let d =
    arr
    |> list.map(fn(row) {
      row
      |> list.index_map(fn(row, i) { #(i, row) })
    })
    |> list.flatten
    |> group_maintaining_order

  yielder.unfold(0, fn(i) {
    case dict.get(d, i) {
      Ok(col) -> yielder.Next(col, i + 1)
      Error(_) -> yielder.Done
    }
  })
  |> yielder.to_list
}

fn split_helper(
  rem: List(String),
  curr_index: Int,
  len: Int,
  curr: StringTree,
  splits: Set(Int),
  out: List(String),
) -> List(String) {
  use <- bool.guard(
    list.is_empty(rem) || curr_index == len,
    [string_tree.to_string(curr), ..out]
      |> list.reverse,
  )
  // TODO kinda dumb but whatevs
  case set.contains(splits, curr_index) {
    False -> {
      let assert [next, ..rem] = rem
      let curr_index = curr_index + 1
      let curr = string_tree.append(curr, next)
      split_helper(rem, curr_index, len, curr, splits, out)
    }
    True -> {
      let assert [next, ..rem] = rem
      let curr_index = curr_index + 1
      let curr = string_tree.append(curr, next)
      let out = [string_tree.to_string(curr), ..out]
      let curr = string_tree.new()
      split_helper(rem, curr_index, len, curr, splits, out)
    }
  }
}

pub fn split_at_indices(s: String, indices: List(Int)) -> List(String) {
  use <- bool.guard(list.is_empty(indices), [s])
  let indices = list.sort(indices, int.compare)
  let assert [first, ..rest] = indices
  let indices = case first {
    0 -> rest
    _ -> indices
  }
  let indices = set.from_list(indices)
  let len = string.length(s)

  split_helper(string.to_graphemes(s), 0, len, string_tree.new(), indices, [])
}
