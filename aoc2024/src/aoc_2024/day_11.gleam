import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/otp/task
import gleam/result
import gleam/string

fn parse_input(input: String) -> List(Int) {
  input
  |> string.split(" ")
  |> list.map(int.parse)
  |> result.values
}

fn count_and_split_digits2(stone: Int) -> #(Int, List(Int)) {
  use <- bool.guard(stone < 10, #(1, [stone]))
  let s_stone = int.to_string(stone)

  let len = string.length(s_stone)
  let assert Ok(half_len) = int.divide(len, 2)

  let left_s = string.slice(s_stone, 0, half_len)
  let right_s = string.slice(s_stone, half_len, half_len)

  let assert Ok(left) = int.parse(left_s)
  let assert Ok(right) = int.parse(right_s)

  #(len, [left, right])
}

fn count_and_split_digits(stone: Int) -> #(Int, List(Int)) {
  use <- bool.guard(stone < 10, #(1, [stone]))
  let assert Ok(digits) = int.digits(stone, 10)
  let len = list.length(digits)
  let assert Ok(half_len) = int.divide(len, 2)
  let assert Ok(rem) = int.remainder(len, 2)
  let half_len = case rem > 0 {
    True -> half_len + 1
    False -> half_len
  }

  let assert [left, right] = list.sized_chunk(digits, half_len)
  let assert Ok(left) = int.undigits(left, 10)
  let assert Ok(right) = int.undigits(right, 10)

  #(len, [left, right])
}

fn replace_stone(stone: Int) -> List(Int) {
  let #(len, lr_digits) = count_and_split_digits(stone)
  case stone, len % 2 == 0 {
    0, _ -> [1]
    _, True -> lr_digits
    _, _ -> [stone * 2024]
  }
}

fn naive_replace_stones(stones: List(Int)) -> List(Int) {
  stones
  |> list.flat_map(replace_stone)
}

pub fn pt_1(input: String) {
  let stones =
    input
    |> parse_input

  // let #(sum, cache) =
  //   stones
  //   |> list.fold(#(0, dict.new()), fn(acc, stone) {
  //     let #(num_stones, a_cache) = acc

  //     let #(r_stones, r_cache) = cached_replace_stone_rep(stone, 24, a_cache)

  //     let l = list.length(r_stones)
  //     let c = dict.combine(a_cache, r_cache, fn(one, other) { other })
  //     #(num_stones + l, c)
  //   })
  //

  stones
  |> list.map(fn(stone) {
    task.async(fn() { cached_replace_stone_rep(stone, 24, dict.new()) })
  })
  |> list.map(task.await_forever)
  |> list.fold(0, fn(acc, res) {
    let #(r_stones, _cache) = res
    let l = list.length(r_stones)
    acc + l
  })
  // cache
  // |> dict.to_list
  // |> list.map(io.debug)

  // sum
}

// fn cached_replace_stone_rep(stone: Int, times: Int, init_cache: Cache) -> #(Int, Cache) {
//   iterator.unfold(#([stone], init_cache), fn(acc) {
//     let #(stones, cache) = acc

//     stones
//     |> list.fold(#(cache, [], times), fn())

//   })
// }

type CacheKey {
  CacheKey(stone: Int, depth: Int)
}

type Cache =
  Dict(CacheKey, List(Int))

fn cached_replace_stone_rep(
  stone: Int,
  curr_depth: Int,
  cache: Cache,
) -> #(List(Int), Cache) {
  let mapped_stones = dict.get(cache, CacheKey(stone: stone, depth: curr_depth))
  case mapped_stones, curr_depth {
    Ok(stones), _ -> #(stones, cache)
    Error(_), 0 -> {
      let stones = replace_stone(stone)
      let cache = dict.insert(cache, CacheKey(stone, 0), stones)
      #(stones, cache)
    }
    Error(_), _ -> {
      let stones = replace_stone(stone)
      let cache = dict.insert(cache, CacheKey(stone, 0), stones)
      let #(stones, cache) =
        stones
        |> list.fold(#([], dict.new()), fn(acc, s) {
          let #(a_stones, a_cache) = acc
          let #(r_stones, r_cache) =
            cached_replace_stone_rep(s, curr_depth - 1, cache)

          #(
            list.concat([a_stones, r_stones]),
            dict.combine(a_cache, r_cache, fn(_one, other) { other }),
          )
        })

      let cache = dict.insert(cache, CacheKey(stone, curr_depth), stones)
      #(stones, cache)
    }
  }
}

pub fn pt_2(input: String) {
  // todo
  let stones =
    input
    |> parse_input

  // let #(sum, cache) =
  //   stones
  //   |> list.fold(#(0, dict.new()), fn(acc, stone) {
  //     let #(num_stones, a_cache) = acc

  //     let #(r_stones, r_cache) = cached_replace_stone_rep(stone, 24, a_cache)

  //     let l = list.length(r_stones)
  //     let c = dict.combine(a_cache, r_cache, fn(one, other) { other })
  //     #(num_stones + l, c)
  //   })
  //

  stones
  |> list.map(fn(stone) {
    task.async(fn() { cached_replace_stone_rep(stone, 74, dict.new()) })
  })
  |> list.map(task.await_forever)
  |> list.fold(0, fn(acc, res) {
    let #(r_stones, _cache) = res
    let l = list.length(r_stones)
    acc + l
  })
  // cache
  // |> dict.to_list
  // |> list.map(io.debug)

  // sum
}
