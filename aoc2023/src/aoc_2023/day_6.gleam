import gleam/int
import gleam/list
import gleam/string

fn get_num_strs_for_line(line: String) {
  let assert [_prefix, num_strs] = string.split(line, ": ")

  num_strs
  |> string.split(on: " ")
  |> list.filter(fn(x) { x != "" && x != " " })
}

fn parse_line_1(line: String) {
  line
  |> get_num_strs_for_line
  |> list.map(fn(x) {
    let assert Ok(num) = int.parse(x)
    num
  })
}

fn parse_line_2(line: String) -> Int {
  let assert Ok(num) =
    line
    |> get_num_strs_for_line
    |> string.join("")
    |> int.parse

  num
}

fn parse_input(input: String) {
  let assert [times, distances] =
    input
    |> string.split(on: "\n")
    |> list.map(parse_line_1)

  #(times, distances)
}

fn parse_input_2(input: String) -> #(Int, Int) {
  let assert [time, distance] =
    input
    |> string.split(on: "\n")
    |> list.map(parse_line_2)

  #(time, distance)
}

fn get_ways_to_win(race_time: Int, distance_to_beat: Int) {
  let distances_traveled =
    list.range(0, race_time / 2)
    |> list.map(fn(button_held_time) {
      let rate = button_held_time
      let remaining_race_time = race_time - button_held_time
      remaining_race_time * rate
    })

  let sum =
    distances_traveled
    |> list.map(fn(distance_traveled) { distance_traveled > distance_to_beat })
    |> list.fold(0, fn(acc, my_boat_won) {
      case my_boat_won {
        True -> acc + 2
        False -> acc
      }
    })

  case race_time % 2 == 0 {
    False -> sum
    True -> sum - 1
  }
}

pub fn pt_1(input: String) {
  let #(times, distances) =
    input
    |> parse_input

  list.zip(times, distances)
  |> list.map(fn(x) { get_ways_to_win(x.0, x.1) })
  |> list.fold(1, int.multiply)
}

pub fn pt_2(input: String) {
  let #(time, distance) =
    input
    |> parse_input_2

  get_ways_to_win(time, distance)
}
