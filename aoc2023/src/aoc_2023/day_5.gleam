import gleam/int
import gleam/io
import gleam/iterator.{type Iterator}
import gleam/list
import gleam/option
import gleam/otp/task
import gleam/result
import gleam/string

type Range =
  #(Int, Int)

fn parse_seeds(seeds_str: String) -> List(Int) {
  let assert [_, seed_nums_str] = string.split(seeds_str, ": ")

  seed_nums_str
  |> string.split(" ")
  |> list.map(fn(x) {
    let assert Ok(num) = int.parse(x)
    num
  })
}

fn parse_mapping_line(mapping_line: String) -> #(Int, Int, Int) {
  let assert [dest_start_range_str, source_start_range_str, len_str] =
    string.split(mapping_line, " ")

  let assert Ok(dest_start_range) = int.parse(dest_start_range_str)
  let assert Ok(source_start_range) = int.parse(source_start_range_str)
  let assert Ok(len) = int.parse(len_str)

  #(dest_start_range, source_start_range, len)
}

fn expand_to_ranges(mapping: #(Int, Int, Int)) -> #(Range, Range) {
  let #(dest_start_range, source_start_range, len) = mapping

  #(#(source_start_range, source_start_range + len - 1), #(
    dest_start_range,
    dest_start_range + len - 1,
  ))
}

fn parse_mapping(mapping_str: String) {
  let assert [_, ..mapping_nums] =
    mapping_str
    |> string.split("\n")

  mapping_nums
  |> list.map(parse_mapping_line)
  |> list.map(expand_to_ranges)
}

fn parse_input_1(input: String) -> #(List(Int), List(List(#(Range, Range)))) {
  let parts =
    input
    |> string.split("\n\n")

  let assert [seeds_str, ..mapping_strs] = parts

  let seeds = parse_seeds(seeds_str)
  let mapping =
    mapping_strs
    |> list.map(parse_mapping)

  #(seeds, mapping)
}

fn parse_input_2(input: String) -> #(List(Range), List(List(#(Range, Range)))) {
  let parts =
    input
    |> string.split("\n\n")

  let assert [seeds_str, ..mapping_strs] = parts

  let seeds = parse_seeds(seeds_str)

  let #(seed_range_starts, seed_range_lens) =
    seeds
    |> list.index_map(fn(i, x) { #(i, x) })
    |> list.partition(fn(index_and_num) { index_and_num.0 % 2 == 0 })
  // |> io.debug

  let seed_ranges =
    list.zip(seed_range_starts, seed_range_lens)
    |> list.map(fn(range_start_and_len_with_index) {
      let #(seed_range_start_with_index, seed_range_len_with_index) =
        range_start_and_len_with_index
      let #(_, seed_range_len) = seed_range_len_with_index
      let #(_, seed_range_start) = seed_range_start_with_index
      #(seed_range_start, seed_range_start + seed_range_len)
    })
  // |> io.debug

  let mapping =
    mapping_strs
    |> list.map(parse_mapping)

  #(seed_ranges, mapping)
}

fn parse_input_2_brute_force(
  input: String,
) -> #(List(Iterator(Int)), List(List(#(Range, Range)))) {
  let parts =
    input
    |> string.split("\n\n")

  let assert [seeds_str, ..mapping_strs] = parts

  let seeds = parse_seeds(seeds_str)

  let #(seed_range_starts, seed_range_lens) =
    seeds
    |> list.index_map(fn(i, x) { #(i, x) })
    |> list.partition(fn(index_and_num) { index_and_num.0 % 2 == 0 })
    |> io.debug

  let seeds =
    list.zip(seed_range_starts, seed_range_lens)
    |> list.map(fn(range_start_and_len_with_index) {
      let #(seed_range_start_with_index, seed_range_len_with_index) =
        range_start_and_len_with_index
      let #(_, seed_range_len) = seed_range_len_with_index
      let #(_, seed_range_start) = seed_range_start_with_index

      iterator.range(seed_range_start, seed_range_start + seed_range_len)
    })
    |> io.debug

  let mapping =
    mapping_strs
    |> list.map(parse_mapping)

  #(seeds, mapping)
}

fn num_in_range(num: Int, range: Range) {
  let #(lower_bound, upper_bound) = range
  num >= lower_bound && num <= upper_bound
}

fn ranges_overlap(r1: Range, r2: Range) {
  r1.0 <= r2.1 && r2.0 <= r1.1
}

fn get_min_from_overlap(r1: Range, r2: Range) {
  case ranges_overlap(r1, r2) {
    True -> Ok(int.min(r1.0, r2.0))
    False -> Error(Nil)
  }
}

fn get_matching_range(num: Int, source_and_dest_ranges: List(#(Range, Range))) {
  source_and_dest_ranges
  |> list.filter(fn(source_and_dest_range) {
    let #(source_range, _dest_range) = source_and_dest_range
    num_in_range(num, source_range)
  })
  |> list.first()
}

fn follow_ranges(seed_num: Int, ranges: List(List(#(Range, Range)))) {
  ranges
  |> list.map_fold(seed_num, fn(curr_num, curr_source_and_dest_ranges) {
    let maybe_matching_source_and_dest =
      get_matching_range(curr_num, curr_source_and_dest_ranges)

    case maybe_matching_source_and_dest {
      Error(_) -> #(curr_num, curr_num)
      Ok(source_and_dest_range) -> {
        let #(source_range, dest_range) = source_and_dest_range
        let diff = curr_num - source_range.0
        let new_num = dest_range.0 + diff
        #(new_num, new_num)
      }
    }
  })
}

pub fn pt_1(input: String) {
  let #(seed_nums, ranges) =
    input
    |> parse_input_1

  seed_nums
  |> list.map(fn(seed_num) { follow_ranges(seed_num, ranges) })
  // Get location
  |> list.map(fn(x) { x.0 })
  |> list.fold(9_999_999_999_999_999_999_999_999_999_999, int.min)
}

pub fn pt_2(input: String) {
  let #(seed_range_iterators, ranges) =
    input
    |> parse_input_2_brute_force

  seed_range_iterators
  |> list.map(fn(iter) {
    task.async(fn() {
      iter
      |> iterator.map(fn(seed_num) { follow_ranges(seed_num, ranges) })
      |> iterator.map(fn(x) { x.0 })
      |> iterator.fold(9_999_999_999_999_999_999_999_999_999_999, int.min)
    })
  })
  |> list.map(task.await_forever)
  |> io.debug
  |> list.fold(9_999_999_999_999_999_999_999_999_999_999, int.min)
}
