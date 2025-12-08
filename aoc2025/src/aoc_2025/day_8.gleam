import gleam/bool
import gleam/dict.{type Dict}
import gleam/float
import gleam/int
import gleam/list
import gleam/set.{type Set}
import gleam/string

type Coord3d {
  Coord3d(x: Float, y: Float, z: Float)
}

type Connection =
  #(Coord3d, Coord3d)

fn distance(c1: Coord3d, c2: Coord3d) -> Float {
  let a1 = float.subtract(c1.x, c2.x)
  let a2 = float.subtract(c1.y, c2.y)
  let a3 = float.subtract(c1.z, c2.z)
  let added =
    [float.multiply(a1, a1), float.multiply(a2, a2), float.multiply(a3, a3)]
    |> list.fold(0.0, float.add)

  let assert Ok(res) = float.square_root(added)
  res
}

fn distance_conn(conn: Connection) {
  distance(conn.0, conn.1)
}

fn parse_input(input: String) {
  use line <- list.map(string.split(input, "\n"))
  let assert [x, y, z] =
    string.split(line, ",")
    |> list.filter_map(int.parse)
    |> list.map(int.to_float)
  Coord3d(x, y, z)
}

fn conn_compare(con1: Connection, con2: Connection) {
  float.compare(distance_conn(con1), distance_conn(con2))
}

fn calc_result(circuits: Dict(Int, Set(Coord3d))) {
  circuits
  |> dict.values
  |> list.map(fn(s) { #(set.size(s), s) })
  |> list.sort(fn(t1, t2) { int.compare(t2.0, t1.0) })
  |> list.take(3)
  |> list.fold(1, fn(product, curr) { product * curr.0 })
}

fn build_circuits(
  connections: List(Connection),
  circuits: Dict(Int, Set(Coord3d)),
  next_id: Int,
  times: Int,
) {
  use <- bool.lazy_guard(times == 0, fn() { calc_result(circuits) })
  let assert [connection, ..rc] = connections
  let containing =
    circuits
    |> dict.to_list
    |> list.filter(fn(t) {
      let s = t.1

      set.contains(s, connection.0) || set.contains(s, connection.1)
    })

  let #(circuits, next_id) = case containing {
    [] -> {
      let circuits =
        [connection.0, connection.1]
        |> set.from_list
        |> dict.insert(circuits, next_id, _)

      #(circuits, next_id + 1)
    }

    _ -> {
      // combine all circuits which contain the points
      let new_circuit =
        containing
        |> list.fold(set.new(), fn(c, conn) { c |> set.union(conn.1) })
        |> set.insert(connection.0)
        |> set.insert(connection.1)

      let assert [first_id, ..rest_ids] =
        containing
        |> list.map(fn(t) { t.0 })

      let circuits =
        rest_ids
        |> list.fold(circuits, fn(c, id) { dict.delete(c, id) })
        |> dict.insert(first_id, new_circuit)

      #(circuits, next_id)
    }
  }

  build_circuits(rc, circuits, next_id, times - 1)
}

fn do_calc(boxes: List(Coord3d), iters: Int) {
  let connections =
    boxes
    |> list.combination_pairs

  let a =
    connections
    |> list.sort(conn_compare)

  build_circuits(a, dict.new(), 0, iters)
}

pub fn pt_1(input: String) {
  input
  |> parse_input
  // |> do_calc(10)
  |> do_calc(1000)
}

pub fn pt_2(_input: String) {
  ""
}
