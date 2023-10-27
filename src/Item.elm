module Item exposing (Item, toItem, toItemList, partitionByTags)


type alias Item =
  { name : String
  , tags : List String
  , needs : List String
  , offers : List String
  }


partitionByTags : List String -> List Item -> (List Item, List Item)
partitionByTags tag_list item_list =
  let
    matchesTags tags item =
      case tags of
        [] ->
          True

        t :: ts ->
          (List.member t item.tags) && (matchesTags ts item)
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


getTags : List String -> List String
getTags contents =
  contents
    |> List.filter (\x -> String.length x > 0)
    |> List.filter (\x -> not <| String.startsWith "+" x)
    |> List.filter (\x -> not <| String.startsWith "-" x)


getNeeds : List String -> List String
getNeeds contents =
  contents
    |> List.filter (String.startsWith "-")
    |> List.map (String.dropLeft 1)


getOffers : List String -> List String
getOffers contents =
  contents
    |> List.filter (String.startsWith "+")
    |> List.map (String.dropLeft 1)
