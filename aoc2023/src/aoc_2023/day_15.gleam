import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string

fn parse_input1(input: String) -> List(String) {
  string.split(input, ",")
}

fn parse_operation(input: String) -> Operation {
  let chars = input |> string.split("")

  case list.find(chars, fn(x) { x == "-" }) {
    Ok(_) -> Remove(string.drop_right(input, 1))
    Error(_) -> {
      let assert [id, val] = string.split(input, "=")
      let assert Ok(int_val) = int.parse(val)

      Set(id, int_val)
    }
  }
}

fn parse_input2(input: String) -> List(Operation) {
  string.split(input, ",")
  |> list.map(parse_operation)
}

fn run_hash(s: String) -> Int {
  s
  |> string.split("")
  |> list.map(string.to_utf_codepoints)
  |> list.flatten
  |> list.map(string.utf_codepoint_to_int)
  |> list.fold(0, fn(codepoint, acc) { { { acc + codepoint } * 17 } % 256 })
}

pub type Operation {
  Remove(id: String)
  Set(id: String, value: Int)
}

pub fn pt_1(input: String) {
  input
  |> parse_input1
  |> list.map(run_hash)
  |> int.sum
}

fn replace_op(l: List(Operation), op: Operation) -> List(Operation) {
  let assert Set(my_id, my_val) = op

  l
  |> list.map(fn(o) {
    case o {
      Set(id, value) -> #(id, value)
      _ -> panic as "for some reason theres a remove key in the list"
    }
  })
  |> list.key_set(my_id, my_val)
  |> list.map(fn(t) { Set(t.0, t.1) })
}

fn upsert_operation(
  op: Option(List(Operation)),
  val: Operation,
) -> List(Operation) {
  case op {
    // TODO probably should be prepending
    Some(ops) -> replace_op(ops, val)
    None -> [val]
  }
}

fn execute_operations(ops: List(Operation)) -> dict.Dict(Int, List(Operation)) {
  let d = dict.new()

  ops
  |> list.map(fn(op) {
    let hash = case op {
      Remove(id) -> run_hash(id)
      Set(id, _) -> run_hash(id)
    }

    #(hash, op)
  })
  |> list.fold(d, fn(acc, entry) {
    let #(hash, op) = entry
    case op {
      Remove(id) -> {
        case dict.get(acc, hash) {
          Error(_) -> acc
          Ok(l) -> {
            l
            |> list.filter(fn(x: Operation) { x.id != id })
            |> dict.insert(acc, hash, _)
          }
        }
      }
      Set(id, val) -> dict.upsert(acc, hash, upsert_operation(_, op))
    }
  })
  |> dict.filter(fn(key, value) {
    !list.is_empty(value)
  })
}

// fn focusing_power()

pub fn pt_2(input: String) {
  input
  |> parse_input2
  |> execute_operations
  |> dict.to_list
  |> list.map(fn(entry) {
    let #(key, val) = entry
    list.index_map(val, fn(item, idx) {
      #(key + 1, item, idx + 1)
    })
  })
  |> list.flatten
  |> list.fold(0, fn(acc, entry) {
    let #(box, op, slot) = entry
    let assert Set(_, focus) = op
    acc + {box * slot * focus}
  })
}
