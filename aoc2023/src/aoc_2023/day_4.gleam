import gleam/dict
import gleam/float
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/string

fn parse_line(line: String) -> #(List(Int), List(Int)) {
  let assert [_game_num, num_str] = string.split(line, on: ": ")

  let assert [winning_numbers_str, my_numbers_str] =
    string.split(num_str, on: " | ")

  let winning_numbers =
    winning_numbers_str
    |> string.split(on: " ")
    |> list.filter_map(int.parse)

  let my_numbers =
    my_numbers_str
    |> string.split(on: " ")
    |> list.filter_map(int.parse)

  #(winning_numbers, my_numbers)
}

fn parse_input(input: String) -> List(#(List(Int), List(Int))) {
  input
  |> string.split(on: "\n")
  |> list.map(parse_line)
}

fn count_winners_for_card(card: #(List(Int), List(Int))) {
  let #(winning_numbers, my_numbers) = card
  my_numbers
  |> list.map(fn(my_number) {
    case list.contains(winning_numbers, my_number) {
      True -> 1.0
      False -> 0.0
    }
  })
  |> list.fold(0.0, float.add)
}

fn score_card_for_count(winner_count: Float) {
  case winner_count {
    0.0 -> 0.0
    x ->
      x
      |> float.subtract(1.0)
      |> int.power(2, _)
      |> result.unwrap(0.0)
  }
}

fn make_card_copies(
  card_count_map: dict.Dict(Int, Float),
  winners_for_card_float: Float,
  curr_index: Int,
) {
  let card_copy_count =
    card_count_map
    |> dict.get(curr_index)
    |> result.unwrap(0.0)
    |> float.truncate

  let winners_for_card =
    winners_for_card_float
    |> float.truncate

  let calc_new_map = fn() {
    // Increment the card counts for the subsequent `winners_for_card` cards.
    // We could have multiple copies of this card, so we increment `card_copy_count_times`
    list.range(curr_index + 1, curr_index + winners_for_card)
    |> list.repeat(times: card_copy_count)
    |> list.flatten
    |> list.fold(card_count_map, fn(curr_map, index) {
      curr_map
      |> dict.upsert(index, fn(entry) {
        case entry {
          option.Some(x) -> float.add(x, 1.0)
          _ -> 0.0
        }
      })
    })
  }

  case winners_for_card {
    0 -> card_count_map
    _ -> calc_new_map()
  }
}

pub fn pt_1(input: String) {
  input
  |> parse_input
  |> list.map(count_winners_for_card)
  |> list.map(score_card_for_count)
  |> list.fold(0.0, float.add)
}

pub fn pt_2(input: String) {
  let winners_per_card =
    input
    |> parse_input
    |> list.map(count_winners_for_card)

  // Maps card id to card count, initialize all card counts to 1.0
  let card_count_map =
    winners_per_card
    |> list.index_map(fn(_, i) { #(i, 1.0) })
    |> dict.from_list

  winners_per_card
  |> list.index_fold(from: card_count_map, with: make_card_copies)
  |> dict.values
  |> list.fold(0.0, float.add)
}
