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