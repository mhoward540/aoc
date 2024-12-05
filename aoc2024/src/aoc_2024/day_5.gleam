import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/iterator
import gleam/list
import gleam/option
import gleam/string

type Placement {
  Before
  After
}

type PageOrderingRule {
  PageOrderingRule(subject: Int, placement: Placement, other: Int)
}

type PageOrdering =
  Dict(Int, List(PageOrderingRule))

fn parse_page_ordering(page_ordering: String) -> List(#(Int, PageOrderingRule)) {
  let assert [a, b] = string.split(page_ordering, "|")
  let assert Ok(a) = int.parse(a)
  let assert Ok(b) = int.parse(b)

  [#(a, PageOrderingRule(a, Before, b)), #(b, PageOrderingRule(b, After, a))]
}

fn parse_page_orderings(page_ordering: String) -> PageOrdering {
  page_ordering
  |> string.split("\n")
  |> list.map(parse_page_ordering)
  |> list.flatten
  |> list.fold(dict.new(), fn(d, item) {
    let #(key, rule) = item
    dict.upsert(d, key, fn(l) {
      case l {
        option.Some(l) -> [rule, ..l]
        option.None -> [rule]
      }
    })
  })
}

fn parse_update_line(update_line: String) -> List(Int) {
  update_line
  |> string.split(",")
  |> list.map(fn(x) {
    let assert Ok(x) = int.parse(x)
    x
  })
}

fn parse_updates(updates: String) -> List(List(Int)) {
  updates
  |> string.split("\n")
  |> list.map(parse_update_line)
}

fn parse_input(input: String) -> #(PageOrdering, List(List(Int))) {
  let assert [page_ordering, updates] = string.split(input, "\n\n")

  let po =
    page_ordering
    |> parse_page_orderings

  let u =
    updates
    |> parse_updates

  #(po, u)
}

fn check_rule(
  po: PageOrdering,
  before: List(Int),
  current: Int,
  after: List(Int),
) -> Bool {
  let assert Ok(rules) = dict.get(po, current)

  let full_list = list.concat([before, after])

  rules
  |> list.map(fn(rule) {
    case rule {
      PageOrderingRule(_s, Before, o) ->
        list.contains(after, o) || !list.contains(full_list, o)
      PageOrderingRule(_s, After, o) ->
        list.contains(before, o) || !list.contains(full_list, o)
    }
  })
  |> list.fold(True, bool.and)
}

fn check_rules(po: PageOrdering, updates: List(Int)) -> Bool {
  let start_acc = #([], -1, updates, True)

  let #(_, _, _, result) =
    updates
    |> list.fold_until(start_acc, fn(acc, update) {
      let #(before, current, after, _res) = acc
      use <- bool.guard(
        list.is_empty(after),
        list.Stop(#(before, current, after, True)),
      )

      let before = list.append(before, [current])
      let #(current, after) = list.split(after, 1)
      let assert [current] = current
      case check_rule(po, before, current, after) {
        True -> list.Continue(#(before, current, after, True))
        False -> list.Stop(#(before, current, after, False))
      }
    })

  result
}

fn check_ordering(
  po: PageOrdering,
  updates: List(List(Int)),
) -> #(List(List(Int)), List(List(Int))) {
  updates
  |> list.fold(#([], []), fn(acc, l) {
    let #(accept, rej) = acc
    case check_rules(po, l) {
      False -> #(accept, [l, ..rej])
      True -> #([l, ..accept], rej)
    }
  })
}

fn get_middle(l: List(Int)) -> Int {
  let len = list.length(l)
  let assert Ok(midpoint) = int.divide(len, 2)
  let assert Ok(res) =
    iterator.from_list(l)
    |> iterator.at(midpoint)

  res
}

fn correct_updates(po: PageOrdering, updates: List(Int)) -> List(Int) {
  updates
  |> list.map(fn(update) {
    let assert Ok(l) = dict.get(po, update)
    // Get all items, from this list of updates, which come after the current update
    let afters =
      list.filter(l, fn(rule) {
        case rule, list.contains(updates, rule.other) {
          PageOrderingRule(_, After, _), True -> True
          _, _ -> False
        }
      })

    #(update, list.length(afters))
  })
  |> list.sort(fn(a, b) {
    // Sort by how many items come after a given item
    int.compare(a.1, b.1)
  })
  |> list.map(fn(a) { a.0 })
}

fn correct_ordering(
  po: PageOrdering,
  updates: List(List(Int)),
) -> List(List(Int)) {
  updates
  |> list.map(correct_updates(po, _))
}

pub fn pt_1(input: String) {
  let #(po, updates) =
    input
    |> parse_input

  let #(accept, _) = check_ordering(po, updates)

  accept
  |> list.map(get_middle)
  |> int.sum
}

pub fn pt_2(input: String) {
  let #(po, updates) =
    input
    |> parse_input

  let #(_accept, reject) = check_ordering(po, updates)

  correct_ordering(po, reject)
  |> list.map(get_middle)
  |> int.sum
}
