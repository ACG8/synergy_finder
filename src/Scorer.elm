module Scorer exposing (..)

import Item exposing (..)
import Set exposing (..)


sortBySynergy : List Item -> List Item -> List Item
sortBySynergy target_list reference_list =
  List.sortBy (\x -> scoreItem x reference_list) target_list
  |> List.reverse


scoreItem : Item -> List Item -> Int
scoreItem item item_list =
  getSynergySummary item item_list
  |> \synergy_summary -> synergy_summary.needs ++ synergy_summary.offers
  |> List.map (Tuple.second)
  |> List.foldl (+) 0


type alias SynergySummary =
  { name : String
  , needs : List (String, Int)
  , offers : List (String, Int)
  }


getSynergySummary : Item -> List Item -> SynergySummary
getSynergySummary item item_list =
  let
    getBondStrength : String -> List (String, Int) -> Int
    getBondStrength bond_name bond_list=
      case bond_list of
        [] ->
          0

        bond :: tail ->
          if Tuple.first bond == bond_name
            then Tuple.second bond
            else getBondStrength bond_name tail

    getTotalBondStrength : List (List (String, Int)) -> String -> Int
    getTotalBondStrength bond_lists bond_name =
      List.map (getBondStrength bond_name) bond_lists
      |> List.foldl (+) 0

    scoreNeedsVerbose : List (String, Int) -> List Item -> List (String, Int)
    scoreNeedsVerbose needs items =
      case needs of
        [] ->
          []

        head :: tail ->
          let
            name = Tuple.first head
            value = Tuple.second head
          in
          getTotalBondStrength (List.map .offers items) name
          |> (*) value
          |> \product -> (name, product) :: scoreNeedsVerbose tail items

    scoreOffersVerbose : List (String, Int) -> List Item -> List (String, Int)
    scoreOffersVerbose offers items =
      case offers of
        [] ->
          []

        head :: tail ->
          let
            name = Tuple.first head
            value = Tuple.second head
          in
          getTotalBondStrength (List.map .needs items) name
          |> (*) value
          |> \product -> (name, product) :: scoreOffersVerbose tail items

  in
  List.filter ((/=) item) item_list
  |> \other_items ->
    { name = item.name
    , needs = scoreNeedsVerbose item.needs other_items
    , offers = scoreOffersVerbose item.offers other_items
    }