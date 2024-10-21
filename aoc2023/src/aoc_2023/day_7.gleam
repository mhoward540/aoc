import gleam/dict
import gleam/int
import gleam/list.{Continue, Stop}
import gleam/order
import gleam/result
import gleam/string

type Hand =
  #(String, String, String, String, String)

const five_of_kind = 7

const four_of_kind = 6

const full_house = 5

const three_of_kind = 4

const two_pair = 3

const one_pair = 2

const high_card = 1

fn parse_line(line: String) -> #(Hand, Int) {
  let assert [hand_str, bid_str] = string.split(line, " ")
  let assert Ok(bid) = int.parse(bid_str)

  let assert [card_1, card_2, card_3, card_4, card_5] =
    string.split(hand_str, "")

  let hand = #(card_1, card_2, card_3, card_4, card_5)

  #(hand, bid)
}

fn get_x_of_kind(x) -> Int {
  case x {
    1 -> high_card
    2 -> one_pair
    3 -> three_of_kind
    4 -> four_of_kind
    5 -> five_of_kind
    _ -> todo
  }
}

fn score_2_grouped_hand(
  _hand_len: Int,
  hand: dict.Dict(String, List(String)),
) -> Int {
  let assert [hand_part_1, hand_part_2] = dict.values(hand)

  case list.length(hand_part_1), list.length(hand_part_2) {
    3, 2 | 2, 3 -> full_house
    2, 2 -> two_pair
    1, x_of_kind | x_of_kind, 1 -> get_x_of_kind(x_of_kind)
    _, _ -> todo
  }
}

fn score_3_grouped_hand(
  _hand_len: Int,
  hand: dict.Dict(String, List(String)),
) -> Int {
  let assert [hand_part_1, hand_part_2, hand_part_3] = dict.values(hand)

  case
    list.length(hand_part_1),
    list.length(hand_part_2),
    list.length(hand_part_3)
  {
    3, 1, 1 | 1, 3, 1 | 1, 1, 3 -> three_of_kind
    2, 2, 1 | 2, 1, 2 | 1, 2, 2 -> two_pair
    1, 1, 2 | 1, 2, 1 | 2, 1, 1 -> one_pair
    1, 1, 1 -> high_card
    _, _, _ -> todo
  }
}

fn score_4_grouped_hand(
  _hand_len: Int,
  hand: dict.Dict(String, List(String)),
) -> Int {
  let assert [hand_part_1, hand_part_2, hand_part_3, hand_part_4] =
    dict.values(hand)

  case
    list.length(hand_part_1),
    list.length(hand_part_2),
    list.length(hand_part_3),
    list.length(hand_part_4)
  {
    1, 1, 1, 1 -> high_card
    1, 1, 1, 2 | 1, 1, 2, 1 | 1, 2, 1, 1 | 2, 1, 1, 1 -> one_pair
    _, _, _, _ -> todo
  }
}

fn score_hand(
  hand_len: Int,
  hand_grouped: dict.Dict(String, List(String)),
) -> Int {
  case hand_len, hand_grouped, list.length(dict.keys(hand_grouped)) {
    handl, _, num_groups if handl == num_groups -> high_card
    handl, _, 1 -> {
      get_x_of_kind(handl)
    }
    _, hand, 2 -> score_2_grouped_hand(hand_len, hand)
    _, hand, 3 -> score_3_grouped_hand(hand_len, hand)
    _, hand, 4 -> score_4_grouped_hand(hand_len, hand)
    _, _, _ -> todo
  }
}

fn score_hand_normal(hand: Hand) -> Int {
  let hand_list = [hand.0, hand.1, hand.2, hand.3, hand.4]

  let grouped = list.group(hand_list, fn(x) { x })

  score_hand(5, grouped)
}

fn score_hand_with_jokers(hand: Hand) -> Int {
  let hand_list = [hand.0, hand.1, hand.2, hand.3, hand.4]

  let grouped = list.group(hand_list, fn(x) { x })

  let num_jokers =
    dict.get(grouped, "J")
    |> result.unwrap([])
    |> list.length

  let num_non_jokers = 5 - num_jokers

  let jokers_filtered = dict.delete(grouped, "J")

  let ranking = score_hand(num_non_jokers, jokers_filtered)

  case num_non_jokers, ranking {
    4, 1 -> 2
    4, 2 -> 4
    4, 3 -> 5
    4, 4 -> 6
    4, 6 -> 7

    3, 1 -> 4
    3, 2 -> 6
    3, 4 -> 7

    2, 1 -> 6
    2, 2 -> 7

    1, 1 -> 7

    0, _ -> 7

    5, _ -> ranking
    _, _ -> todo
  }
}

fn parse_input(input: String) {
  input
  |> string.split(on: "\n")
  |> list.map(parse_line)
}

fn hand_to_list(hand: Hand) -> List(String) {
  let #(card_1, card_2, card_3, card_4, card_5) = hand
  [card_1, card_2, card_3, card_4, card_5]
}

fn card_to_val(card: String) -> Int {
  case card {
    "A" -> 14
    "K" -> 13
    "Q" -> 12
    "J" -> 11
    "T" -> 10
    x -> {
      let assert Ok(num) = int.parse(x)
      num
    }
  }
}

fn card_to_val_jokers(card: String) -> Int {
  case card {
    "A" -> 14
    "K" -> 13
    "Q" -> 12
    "J" -> 0
    "T" -> 10
    x -> {
      let assert Ok(num) = int.parse(x)
      num
    }
  }
}

fn compare_tied_hands(
  hand_a_tup: Hand,
  hand_b_tup: Hand,
  card_conversion: fn(String) -> Int,
) {
  let hand_a = hand_to_list(hand_a_tup)
  let hand_b = hand_to_list(hand_b_tup)

  list.zip(hand_a, hand_b)
  |> list.fold_until(order.Eq, fn(_, cards) {
    let #(card_a, card_b) = cards
    let comparison =
      int.compare(card_conversion(card_a), card_conversion(card_b))

    case comparison {
      order.Eq -> Continue(order.Eq)
      x -> Stop(x)
    }
  })
}

fn sort_tied_hands(
  t: List(#(Int, #(Hand, Int))),
  card_conversion: fn(String) -> Int,
) {
  t
  |> list.sort(fn(curr_t, other_t) {
    let #(_score, #(hand_a, _bid)) = curr_t
    let #(_score, #(hand_b, _bid)) = other_t
    compare_tied_hands(hand_a, hand_b, card_conversion)
  })
}

pub fn pt_1(input: String) {
  let hands_and_bids =
    input
    |> parse_input

  let scores =
    hands_and_bids
    |> list.map(fn(x) { score_hand_normal(x.0) })

  let grouped_scores =
    list.zip(scores, hands_and_bids)
    |> list.group(fn(x) { x.0 })

  grouped_scores
  |> dict.values
  |> list.map(sort_tied_hands(_, card_to_val))
  |> list.flatten
  |> list.index_fold(0, fn(sum, x, index) {
    let #(_score, #(_hand, bid)) = x
    let score_for_hand = { index + 1 } * bid
    sum + score_for_hand
  })
}

pub fn pt_2(input: String) {
  let hands_and_bids =
    input
    |> parse_input

  let scores =
    hands_and_bids
    |> list.map(fn(x) { score_hand_with_jokers(x.0) })

  let grouped_scores =
    list.zip(scores, hands_and_bids)
    |> list.group(fn(x) { x.0 })

  grouped_scores
  |> dict.values
  |> list.map(sort_tied_hands(_, card_to_val_jokers))
  |> list.flatten
  |> list.index_fold(0, fn(sum, x, index) {
    let #(_score, #(_hand, bid)) = x
    let score_for_hand = { index + 1 } * bid
    sum + score_for_hand
  })
}
