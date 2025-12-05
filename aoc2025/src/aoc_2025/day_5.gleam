import gleam/bool
import gleam/int
import gleam/list
import gleam/string

type Range {
  Range(start: Int, end: Int)
}

fn parse_ranges(ranges: String) -> List(Range) {
  ranges
  |> string.split("\n")
  |> list.map(fn(line) {
    let assert [start, end] =
      line
      |> string.split("-")

    let assert Ok(start) = int.parse(start)
    let assert Ok(end) = int.parse(end)

    Range(start, end)
  })
}

fn parse_input(input: String) {
  let assert [ranges, iids] = string.split(input, "\n\n")

  let r = parse_ranges(ranges)

  let iids =
    iids
    |> string.split("\n")
    |> list.filter_map(int.parse)

  #(r, iids)
}

fn between(num: Int, range: Range) {
  num >= range.start && num <= range.end
}

fn ranges_overlap(a: Range, b: Range) {
  between(a.start, b)
  || between(a.end, b)
  || between(b.start, a)
  || between(b.end, a)
}

fn merge(a: Range, b: Range) {
  let start = int.min(a.start, b.start)
  let end = int.max(a.end, b.end)

  Range(start, end)
}

fn merge_ranges_helper(l: Range, r: Range, rem: List(Range), out: List(Range)) {
  case ranges_overlap(l, r), list.is_empty(rem) {
    True, True -> {
      [merge(l, r), ..out]
    }
    False, True -> {
      [l, r, ..out]
    }
    True, False -> {
      let l = merge(l, r)
      let assert [r, ..rem] = rem
      merge_ranges_helper(l, r, rem, out)
    }
    False, False -> {
      let out = [l, ..out]
      let l = r
      let assert [r, ..rem] = rem
      merge_ranges_helper(l, r, rem, out)
    }
  }
}

fn merge_ranges(ranges: List(Range)) {
  let ranges =
    ranges
    |> list.sort(fn(a, b) { int.compare(a.start, b.start) })

  use <- bool.guard(list.length(ranges) <= 1, ranges)
  let assert [l, r, ..rem] = ranges

  merge_ranges_helper(l, r, rem, [])
}

fn in_any_range(num: Int, ranges: List(Range)) {
  ranges
  |> list.any(between(num, _))
}

pub fn pt_1(input: String) {
  let #(ranges, iids) =
    input
    |> parse_input

  let ranges = merge_ranges(ranges)

  iids
  |> list.count(in_any_range(_, ranges))
}

pub fn pt_2(input: String) {
  let #(ranges, _) =
    input
    |> parse_input

  let ranges = merge_ranges(ranges)

  ranges
  |> list.map(fn(r) { { r.end - r.start } + 1 })
  |> int.sum
}
