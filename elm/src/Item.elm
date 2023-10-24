module Item exposing (Item, toItem, toItemList)


type alias Item =
  { name : String
  , tags : List String
  , needs : List String
  , offers : List String
  }


toItemList : String -> List Item
toItemList csv =
  csv
    |> String.lines
    |> List.filterMap toItem


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
