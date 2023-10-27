module Scorer exposing (..)

import Item exposing (..)



sortByMargin : List Item -> List Item -> List Item
sortByMargin target_list reference_list =
  List.sortBy (\x -> scoreMargin x reference_list) target_list
  |> List.reverse


sortByRemoval : List Item -> List Item
sortByRemoval target_list =
  List.sortBy (\x -> scoreRemoval x target_list) target_list


getSupport : Item -> Item -> Int --Support offered by first item to second
getSupport item_1 item_2 =
    case item_1.offers of
      [] ->
        0

      x :: xs ->
        (if List.member x item_2.needs then 1 else 0) + (getSupport { item_1 | offers = xs } item_2)


getSynergy : Item -> Item -> Int
getSynergy item_1 item_2 =
  (getSupport item_1 item_2) + (getSupport item_2 item_1)


scoreMargin : Item -> List Item -> Int
scoreMargin item item_list =
  List.map (getSynergy item) item_list
  |> List.foldl (+) 0


-- Score an item without counting it as part of given list

scoreRemoval : Item -> List Item -> Int
scoreRemoval item item_list =
  List.filter (\x -> x /= item) item_list
  |> scoreMargin item


scoreList : List Item -> Int
scoreList item_list =
  case item_list of
    [] ->
      0

    x :: xs ->
      (scoreMargin x xs) + (scoreList xs)


type alias SynergySummary =
  { name : String
  , needs : List (String, Int)
  , offers : List (String, Int)
  }


scoreNeedsVerbose : Item -> List Item -> List (String, Int)
scoreNeedsVerbose item item_list =
  case item.needs of
    [] ->
      []

    x :: xs ->
      List.map
        (\candidate_item -> if List.member x candidate_item.offers then 1 else 0)
        item_list
      |> List.foldl (+) 0
      |> \sum ->
        (x, sum) :: scoreNeedsVerbose { item | needs = xs } item_list


scoreOffersVerbose : Item -> List Item -> List (String, Int)
scoreOffersVerbose item item_list =
  case item.offers of
  [] ->
    []

  x :: xs ->
    List.map
      (\candidate_item -> if List.member x candidate_item.needs then 1 else 0)
      item_list
    |> List.foldl (+) 0
    |> \sum ->
      (x, sum) :: scoreOffersVerbose { item | offers = xs } item_list


scoreRemovalVerbose : Item -> List Item -> SynergySummary
scoreRemovalVerbose item item_list =
  List.filter (\x -> x /= item) item_list
  |> \other_items ->
    { name = item.name
    , needs = scoreNeedsVerbose item other_items
    , offers = scoreOffersVerbose item other_items
    }