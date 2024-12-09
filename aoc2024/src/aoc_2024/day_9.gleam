import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string

type Fileblock {
  Fileblock(content: String, id: Int)
}

type Layout {
  Layout(max_index: Int, files: Dict(Int, Fileblock))
}

fn parse_input(input: String) -> Layout {
  let l =
    input
    |> string.split("")

  let l = case list.length(l) % 2 == 0 {
    True -> l
    False -> list.append(l, ["0"])
  }

  let #(files, free_spaces) =
    l
    |> list.index_map(fn(x, i) { #(x, i) })
    |> list.partition(fn(t) { int.is_even(t.1) })

  let full_list =
    list.zip(files, free_spaces)
    |> list.index_map(fn(t, id) {
      let #(#(file, _), #(free_space, _)) = t
      let assert Ok(file) = int.parse(file)
      let assert Ok(free_space) = int.parse(free_space)
      let str_id = int.to_string(id)

      let a = list.repeat(Fileblock(content: str_id, id: id), file)
      let b = list.repeat(Fileblock(content: ".", id: -1), free_space)
      list.concat([a, b])
    })
    |> list.flatten

  let f =
    full_list
    |> list.index_map(fn(x, i) { #(i, x) })
    |> dict.from_list

  Layout(max_index: list.length(full_list) - 1, files: f)
}

fn compaction(l: Int, r: Int, d: Dict(Int, Fileblock)) -> Dict(Int, Fileblock) {
  use <- bool.guard(l >= r, d)
  let maybe_l_block = dict.get(d, l)
  // |> io.debug
  let maybe_r_block = dict.get(d, r)
  // |> io.debug
  // io.debug("")
  use <- bool.guard(result.is_error(maybe_l_block), d)
  use <- bool.guard(result.is_error(maybe_r_block), d)
  let assert Ok(l_block) = maybe_l_block
  let assert Ok(r_block) = maybe_r_block

  case l_block.id, r_block.id {
    -1, -1 -> {
      compaction(l, r - 1, d)
    }
    -1, _ -> {
      // io.debug("swap " <> l_block.content <> " " <> r_block.content)
      let d =
        d
        |> dict.insert(r, l_block)
        |> dict.insert(l, r_block)

      compaction(l + 1, r - 1, d)
    }
    _, -1 -> {
      compaction(l + 1, r - 1, d)
    }
    _, _ -> {
      compaction(l + 1, r, d)
    }
  }
}

fn compact_files(layout: Layout) -> Layout {
  let #(files, max_index) = #(layout.files, layout.max_index)
  let d = compaction(0, max_index, files)
  Layout(max_index, d)
}

fn print_layout(l: Layout) -> Layout {
  list.range(0, l.max_index)
  |> list.map(fn(index) {
    let assert Ok(entry) = dict.get(l.files, index)
    entry.content
  })
  |> string.join("")
  |> io.debug

  l
}

pub fn pt_1(input: String) {
  // io.debug("")
  let l =
    input
    |> parse_input
    |> compact_files
    // |> print_layout

  list.range(0, l.max_index)
  |> list.fold(0, fn(acc, index) {
    let assert Ok(entry) = dict.get(l.files, index)
    let left_mult = int.max(0, entry.id)
    acc + { left_mult * index }
  })
}

pub fn pt_2(input: String) {
  todo as "part 2 not implemented"
}
