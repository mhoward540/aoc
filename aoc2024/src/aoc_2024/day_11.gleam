import gleam/bool
import gleam/dict.{type Dict}
import gleam/float
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/otp/task
import gleam/result
import gleam/string
import gleam_community/maths/elementary

fn parse_input(input: String) -> List(Int) {
  input
  |> string.split(" ")
  |> list.map(int.parse)
  |> result.values
}

fn stone_len(stone: Int) -> Int {
  use <- bool.guard(stone < 10, 1)
  let f_stone = int.to_float(stone)
  let assert Ok(len) = elementary.logarithm_10(f_stone)
  float.truncate(float.floor(len)) + 1
}

fn count_and_split_digits(stone: Int) -> #(Int, List(Int)) {
  use <- bool.guard(stone < 10, #(1, [stone]))
  let f_stone = int.to_float(stone)
  let len = stone_len(stone)
  let assert Ok(half_len) = int.divide(len, 2)
  let assert Ok(rem) = int.remainder(len, 2)
  let half_len = case rem > 0 {
    True -> half_len + 1
    False -> half_len
  }

  let assert Ok(p) = int.power(10, int.to_float(half_len))
  let assert Ok(f_left) = float.divide(f_stone, p)
  let assert Ok(f_right) = float.modulo(f_stone, p)
  let left = float.truncate(f_left)
  let right = float.truncate(f_right)
  #(len, [left, right])
}

fn replace_stone(stone: Int) -> List(Int) {
  use <- bool.guard(stone == 0, [1])
  let len = stone_len(stone)
  use <- bool.guard(len % 2 == 0, { count_and_split_digits(stone).1 })

  [stone * 2024]
}

fn replaced_stone_len(stone: Int) -> Int {
  let #(len, lr_digits) = count_and_split_digits(stone)
  case stone, len % 2 == 0 {
    0, _ -> 1
    _, True -> 2
    _, _ -> 1
  }
}

type CacheKey {
  CacheKey(stone: Int, depth: Int)
}

type Cache2 =
  Dict(CacheKey, Int)

fn cached_replace_stone_rep2(
  stone: Int,
  curr_depth: Int,
  cache: Cache2,
) -> #(Int, Cache2) {
  // io.debug("calc ")
  // io.debug(#(stone, curr_depth))
  // io.debug("")
  let mapped_stones = dict.get(cache, CacheKey(stone: stone, depth: curr_depth))
  case mapped_stones, curr_depth {
    Ok(stones), _ -> #(stones, cache)
    Error(_), 0 -> {
      let stones = replaced_stone_len(stone)
      let cache = dict.insert(cache, CacheKey(stone, 0), stones)
      #(stones, cache)
    }
    Error(_), _ -> {
      let stones = replace_stone(stone)
      let l = list.length(stones)
      let i_cache = dict.insert(cache, CacheKey(stone, 0), l)
      let #(stones, cache) =
        stones
        |> list.fold(#(0, i_cache), fn(acc, s) {
          let #(a_stones, a_cache) = acc
          let #(r_stones, r_cache) =
            cached_replace_stone_rep2(s, curr_depth - 1, a_cache)

          #(
            a_stones + r_stones,
            dict.combine(a_cache, r_cache, fn(_one, other) { other }),
          )
        })

      let cache = dict.insert(cache, CacheKey(stone, curr_depth), stones)
      #(stones, cache)
    }
  }
}

fn do_part(input: String, reps: Int, init_cache: Cache2) {
  let stones =
    input
    |> parse_input

  let #(sum, cache) =
    stones
    |> list.fold(#(0, init_cache), fn(acc, stone) {
      let #(count, a_cache) = acc
      let #(r_stones, r_cache) =
        cached_replace_stone_rep2(stone, reps - 1, a_cache)
      io.debug(r_cache)
      #(r_stones + count, r_cache)
    })
}

pub fn pt_1(input: String) {
  let #(p1, c) = do_part(input, 25, dict.new())
  io.debug(p1)
  let #(p2, c2) = do_part(input, 75, c)

  io.debug(#(p1, p2))
}

pub fn pt_2(input: String) {
  todo
  // do_part(input, 75)
}
