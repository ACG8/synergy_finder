module Item exposing (..)

import Set exposing (Set)

type alias Item =
  { name : String
  , tags : List String
  , needs : List String
  , offers : List String
  }


partitionByFilter : List String -> List Item -> (List Item, List Item)
partitionByFilter tag_list item_list =
  let
    matchesTags tags item =
      case tags of
        [] ->
          True

        t :: ts ->
          ( List.member t <| item.tags ++ item.needs ++ item.offers ) && (matchesTags ts item)
  in
  List.partition (matchesTags tag_list) item_list


toItemList : String -> List Item
toItemList csv =
  csv
    |> String.lines
    |> List.filterMap toItem
    |> List.filter (\item -> item.name /= "")


toItem : String -> Maybe Item
toItem csv_line =
  let
    getTags contents =
      contents
        |> List.filter (\x -> String.length x > 0)
        |> List.filter (\x -> not <| String.startsWith "+" x)
        |> List.filter (\x -> not <| String.startsWith "-" x)

    getNeeds contents =
      contents
        |> List.filter (String.startsWith "-")
        |> List.map (String.dropLeft 1)


    getOffers contents =
      contents
        |> List.filter (String.startsWith "+")
        |> List.map (String.dropLeft 1)
  in
  csv_line
    |> String.split ","
    |> \entries ->
      case entries of
        [] ->
          Nothing

        x :: xs ->
          Just
            { name = x
            , tags = getTags xs
            , needs = getNeeds xs
            , offers = getOffers xs
            }

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
          Set.fromList head.needs
          |> Set.union (Set.fromList head.offers)
          |> Set.union (getBonds tail)
  in
  ItemFilter (getTags item_list) <| getBonds item_list




getTagsFromList : List Item -> Set String
getTagsFromList item_list =
  case item_list of
    [] ->
      Set.empty

    item :: rest ->
      Set.union (Set.fromList item.tags) <| getTagsFromList rest


