import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/string

fn parse_line(line: String) -> #(String, List(Int)) {
  let assert [springs, counts_str] =
    line
    |> string.split(" ")

  let counts =
    counts_str
    |> string.split(",")
    |> list.map(fn(x) {
      let assert Ok(num) = int.parse(x)
      num
    })

  #(springs, counts)
}

fn list_all_combinations(springs: String) -> List(String) {
  let char_map =
    springs
    |> string.split("")
    |> list.index_map(fn(x, i) { #(i, x) })
    |> dict.from_list

  let q_marks =
    char_map
    |> dict.to_list
    |> list.filter(fn(index_and_char) {
      let #(_index, char) = index_and_char
      char == "?"
    })

  list.range(0, list.length(q_marks))
  |> list.map(fn(combo_len) {
    list.combinations(q_marks, combo_len)
    |> list.map(fn(spring_indexes) {
      spring_indexes
      |> list.map(fn(x) { x.0 })
      |> list.fold(
        char_map,
        // replace all indexes in this specific combination to #
        fn(curr_map, spring_index) {
          curr_map
          |> dict.insert(spring_index, "#")
        },
      )
      |> dict.to_list
      |> list.sort(fn(a, b) { int.compare(a.0, b.0) })
      |> list.map(fn(x) { x.1 })
      |> string.join("")
      // replace all remaining question marks with .
      |> string.replace("?", ".")
    })
  })
  |> list.flatten
}

fn satisfies_counts(springs: String, counts: List(Int)) -> Bool {
  let clusters =
    springs
    |> string.split(".")
    |> list.filter(fn(s) { s != "" })

  let cluster_lengths_match = fn() {
    list.zip(counts, clusters)
    |> list.all(fn(count_and_cluster) {
      let #(count, cluster) = count_and_cluster
      string.length(cluster) == count
    })
  }

  case list.length(clusters) == list.length(counts) {
    False -> False
    True -> cluster_lengths_match()
  }
}

fn calculate_combinations(springs: String, counts: List(Int)) -> Int {
  springs
  |> list_all_combinations
  |> list.map(satisfies_counts(_, counts))
  |> list.filter(fn(x) { x })
  |> list.length
  |> io.debug
}

fn count_occurences(haystack: String, needle_str: String) {
  let len = string.length(needle_str)
  let needle = string.split(needle_str, "")

  haystack
  |> string.split("")
  |> list.window(len)
  |> list.fold(0, fn(acc, window) {
    case window == needle {
      True -> acc + 1
      False -> acc
    }
  })
}

fn solve_cluster(cluster: String, spring_count: Int) -> Int {
  0
}

fn calculate_combinations_2(springs: String, counts: List(Int)) -> Int {
  let maybe_clusters =
    springs
    |> string.split(".")
    |> list.filter(fn(x) { x != "" })

  case list.length(counts) == list.length(maybe_clusters) {
    True -> {
      let c =
        list.zip(maybe_clusters, counts)
        |> list.map(fn(x) { solve_cluster(x.0, x.1) })

      io.debug(#(springs, c))

      0
    }
    False -> 0
  }
}

fn parse_input(input: String) {
  input
  |> string.split("\n")
  |> list.map(parse_line)
}

pub fn pt_1(input: String) {
  todo
  // let springs_and_counts =
  //   input
  //   |> parse_input

  // springs_and_counts
  // |> list.map(fn(x) { calculate_combinations(x.0, x.1) })
  // |> list.fold(0, int.add)
}

pub fn pt_2(input: String) {
  let springs_and_counts =
    input
    |> parse_input

  springs_and_counts
  |> list.length
  |> io.debug

  springs_and_counts
  |> list.map(fn(x) { calculate_combinations_2(x.0, x.1) })
  |> list.fold(0, int.add)
}
