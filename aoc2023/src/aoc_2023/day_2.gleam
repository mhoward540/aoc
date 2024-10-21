import gleam/int
import gleam/list
import gleam/string

pub type Day2Errors {
  NotParseable
}

pub type Color {
  Red
  Blue
  Green
}

pub type Trial {
  Trial(red: Int, green: Int, blue: Int)
}

fn parse_game(curr_trial: Trial, curr_throw: String) {
  let assert [num_s, color_s] = string.split(curr_throw, on: " ")

  let color = case color_s {
    "red" -> Ok(Red)
    "green" -> Ok(Green)
    "blue" -> Ok(Blue)
    _ -> Error(NotParseable)
  }

  let num = int.parse(num_s)

  case num, color {
    Ok(n), Ok(Red) ->
      Trial(red: n, green: curr_trial.green, blue: curr_trial.blue)
    Ok(n), Ok(Green) ->
      Trial(red: curr_trial.red, green: n, blue: curr_trial.blue)
    Ok(n), Ok(Blue) ->
      Trial(red: curr_trial.red, green: curr_trial.green, blue: n)
    _, _ -> curr_trial
  }
}

fn parse_trial(trials_str: String) {
  trials_str
  |> string.split(on: ", ")
  |> list.fold(Trial(0, 0, 0), parse_game)
}

fn get_trials_for_line(line: String) {
  let assert [_game_num_str, trials_str] =
    line
    |> string.split(on: ": ")

  trials_str
  |> string.split("; ")
  |> list.map(parse_trial)
}

fn maxes_for_game(game: List(Trial)) {
  game
  |> list.fold(Trial(-1, -1, -1), fn(max_trials, curr_trial) {
    Trial(
      int.max(max_trials.red, curr_trial.red),
      int.max(max_trials.green, curr_trial.green),
      int.max(max_trials.blue, curr_trial.blue),
    )
  })
}

fn game_is_possible(game: List(Trial)) {
  case maxes_for_game(game) {
    Trial(r, g, b) if r <= 12 && g <= 13 && b <= 14 -> True
    _ -> False
  }
}

fn sum_games(curr_sum: Int, result_tuple: #(Int, Bool)) {
  case result_tuple {
    #(game_index, True) -> curr_sum + game_index
    #(_, False) -> curr_sum
  }
}

pub fn pt_1(input: String) {
  input
  |> string.split(on: "\n")
  |> list.map(get_trials_for_line)
  |> list.map(game_is_possible)
  |> list.index_map(fn(x, i) { #(i + 1, x) })
  |> list.fold(0, sum_games)
}

fn sum_game_powers(curr_sum: Int, curr_trial: Trial) {
  curr_sum + { curr_trial.red * curr_trial.green * curr_trial.blue }
}

pub fn pt_2(input: String) {
  input
  |> string.split(on: "\n")
  |> list.map(get_trials_for_line)
  |> list.map(maxes_for_game)
  |> list.fold(0, sum_game_powers)
}
