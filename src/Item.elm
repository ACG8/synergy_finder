module Item exposing (..)

import Set exposing (Set)

type alias Item =
  { name : String
  , tags : List String
  , needs : List (String, Int)
  , offers : List (String, Int)
  }


partitionByFilter : List String -> List Item -> (List Item, List Item)
partitionByFilter tag_list item_list =
  let
    matchesTags tags item =
      case tags of
        [] ->
          True

        t :: ts ->
          item.tags
          |> (++) (List.map Tuple.first item.needs)
          |> (++) (List.map Tuple.first item.offers)
          |> List.member t
          |> (&&) (matchesTags ts item)
  in
  List.partition (matchesTags tag_list) item_list


toItemList : String -> List Item
toItemList csv =
  let
    getTags contents =
      contents
        |> List.filter (\x -> String.length x > 0)
        |> List.filter (\x -> not <| String.contains "+" x)
        |> List.filter (\x -> not <| String.contains "/" x)

    getNeeds header contents =
      case (header, contents) of
        (_, []) ->
          []

        ([], _) ->
          []

        (h :: hs, c :: cs) ->
          String.indices "/" c
          |> List.length
          |> \count ->
            if count > 0
              then (h, count) :: (getNeeds hs cs)
              else getNeeds hs cs

    getOffers header contents =
      case (header, contents) of
        (_, []) ->
          []

        ([], _) ->
          []

        (h :: hs, c :: cs) ->
          String.indices "+" c
          |> List.length
          |> \count ->
            if count > 0
              then (h, count) :: (getOffers hs cs)
              else getOffers hs cs

    tailOfLine line =
      String.split "," line
      |> \cells ->
        case cells of
          [] ->
            []

          first :: rest ->
            rest

    toItem header line =
      String.split "," line
      |> \cells ->
        case cells of
          [] ->
            Nothing

          name :: attributes ->
            Just
              { name = name
              , tags = getTags attributes
              , needs = getNeeds header attributes
              , offers = getOffers header attributes
              }
  in
  csv
    |> String.lines
    |> \lines ->
      case lines of
        [] ->
          []

        first_line :: other_lines ->
          List.filterMap (toItem <| tailOfLine first_line) other_lines
          |> List.filter (\item -> item.name /= "")


type alias ItemFilter =
  { tags : Set String
  , bonds : Set String
  }


listToItemFilter : List Item -> ItemFilter
listToItemFilter item_list =
  let
    getTags items =
      case items of
        [] ->
          Set.empty

        head :: tail ->
          Set.union (Set.fromList head.tags) <| getTagsFromList tail

    getBonds items =
      case items of
        [] ->
          Set.empty

        head :: tail ->
          getBonds tail
          |> Set.union (Set.fromList <| List.map Tuple.first head.needs)
          |> Set.union (Set.fromList <| List.map Tuple.first head.offers)
  in
  ItemFilter (getTags item_list) <| getBonds item_list


getTagsFromList : List Item -> Set String
getTagsFromList item_list =
  case item_list of
    [] ->
      Set.empty

    item :: rest ->
      Set.union (Set.fromList item.tags) <| getTagsFromList rest


