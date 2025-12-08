import gleam/dict
import gleam/float
import gleam/int
import gleam/list
import gleam/option
import gleam/order
import gleam/set
import gleam/string

type Coord3d {
  Coord3d(x: Float, y: Float, z: Float)
}

fn distance(c1: Coord3d, c2: Coord3d) {
  let a1 = float.subtract(c1.x, c2.x)
  let a2 = float.subtract(c1.y, c2.y)
  let a3 = float.subtract(c1.z, c2.z)
  let added =
    [float.multiply(a1, a1), float.multiply(a2, a2), float.multiply(a3, a3)]
    |> list.fold(0.0, float.add)

  let assert Ok(res) = float.square_root(added)
  res
}

fn parse_input(input: String) {
  use line <- list.map(string.split(input, "\n"))
  let assert [x, y, z] =
    string.split(line, ",")
    |> list.filter_map(int.parse)
    |> list.map(int.to_float)
  Coord3d(x, y, z)
}

pub fn pt_1(input: String) {
  let zero = Coord3d(0.0, 0.0, 0.0)

  let box_map =
    input
    |> parse_input
    |> list.index_map(fn(x, i) { #(i, x) })
    |> list.combination_pairs
    |> dict.from_list

  let neighbor_map =
    box_map
    |> dict.to_list
    |> list.fold(dict.new(), fn(acc, pair) {
      let #(a_pair, b_pair) = pair
      let #(a_id, a) = a_pair
      let #(b_id, b) = b_pair

      let dist = distance(a, b)
      let acc =
        dict.upsert(acc, a_pair, fn(entry) {
          case entry {
            option.None -> #(b, b_id, dist)
            option.Some(thing) -> {
              let #(_, _, thing_dist) = thing
              case float.compare(dist, thing_dist) {
                order.Lt -> #(b, b_id, dist)
                _ -> thing
              }
            }
          }
        })

      let acc =
        dict.upsert(acc, b_pair, fn(entry) {
          case entry {
            option.None -> #(a, a_id, dist)
            option.Some(thing) -> {
              let #(_, _, thing_dist) = thing
              case float.compare(dist, thing_dist) {
                order.Lt -> #(a, a_id, dist)
                _ -> thing
              }
            }
          }
        })
    })
    |> echo

  neighbor_map
  |> dict.to_list
  |> list.fold([], fn(sets, pair) {
    let #(k, v) = pair
    let #(a_id, a) = k
    let #(b, b_id, _) = v

    let set_map =
      sets
      |> list.index_map(fn(sett, i) { #(i, sett) })
      |> dict.from_list

    let containing_sets =
      set_map
      |> dict.to_list
      |> list.filter_map(fn(t) {
        let #(i, sett) = t
        case set.contains(sett, a_id) || set.contains(sett, b_id) {
          True -> Ok(i)
          False -> Error("")
        }
      })

    echo containing_sets

    let set_map = case containing_sets {
      [cs] -> {
        let assert Ok(s) = dict.get(set_map, cs)
        let new_set =
          s
          |> set.insert(a_id)
          |> set.insert(b_id)

        dict.insert(set_map, cs, new_set)
      }
      [] -> {
        dict.insert(set_map, 8_675_309, [a_id, b_id] |> set.from_list)
      }
      matching_sets -> {
        let assert [fs, ..rest] = matching_sets
        let new_set =
          matching_sets
          |> list.fold(set.new(), fn(ns, index) {
            let assert Ok(os) = dict.get(set_map, index)
            set.union(ns, os)
          })

        rest
        |> list.fold(set_map, dict.delete)
        |> dict.insert(fs, new_set)
      }
    }

    dict.values(set_map)
  })
}

pub fn pt_2(input: String) {
  todo as "part 2 not implemented"
}
