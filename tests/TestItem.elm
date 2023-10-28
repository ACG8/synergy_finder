module TestItem exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import Item exposing (..)
import Set exposing (Set)


testCsv = """Item,Type,Class,Oxygen,Fuel,Heat,Smoke,Moisture,Cool
Fire,Reaction,Element,/,//,++/,++,,
Water,Fluid,Element,,,,,+++,/
Air,Fluid,Element,+++,,,,,
Earth,Solid,Element,/,+,,/,//,"""


toItemList =
    test "item list should contain correct items" <|
        \_ -> Item.toItemList testCsv
            |> Expect.equal
                [ { name = "Fire"
                  , tags = ["Reaction", "Element"]
                  , needs = [("Oxygen", 1), ("Fuel", 2), ("Heat", 1)]
                  , offers = [("Heat", 2), ("Smoke", 2)]
                }
                , { name = "Water"
                  , tags = ["Fluid", "Element"]
                  , needs = [("Cool", 1)]
                  , offers = [("Moisture", 3)]
                }
                , { name = "Air"
                  , tags = ["Fluid", "Element"]
                  , needs = []
                  , offers = [("Oxygen", 3)]
                }
                , { name = "Earth"
                  , tags = ["Solid", "Element"]
                  , needs = [("Oxygen", 1), ("Smoke", 1), ("Moisture", 2)]
                  , offers = [("Fuel", 1)]
                }
                ]


listToItemFilter =
    test "listToItemFilter should contain correct ItemFilter" <|
        \_ -> Item.toItemList testCsv
            |> Item.listToItemFilter
            |> Expect.equal
                { tags = Set.fromList ["Reaction", "Element", "Fluid", "Solid"]
                , bonds = Set.fromList ["Oxygen", "Fuel", "Heat", "Smoke", "Cool", "Moisture"]
            }


getTagsFromList =
    test "item list should have all tags" <|
    \_ ->
        Item.toItemList testCsv
        |> Item.getTagsFromList
        |> Expect.equal (Set.fromList ["Reaction", "Element", "Fluid", "Solid"])


partitionByFilter =
    let
        fire = Item "Fire" ["Reaction", "Element"] [("Oxygen", 1), ("Fuel", 2), ("Heat", 1)] [("Heat", 2), ("Smoke", 2)]

        water = Item "Water" ["Fluid", "Element"] [("Cool", 1)] [("Moisture", 3)]

        air = Item "Air" ["Fluid", "Element"] [] [("Oxygen", 3)]

        earth = Item "Earth" ["Solid", "Element"] [("Oxygen", 1), ("Smoke", 1), ("Moisture", 2)] [("Fuel", 1)]
    in
    test "item list should be split into items with ALL tags and items without" <|
    \_ ->

        Item.toItemList testCsv
        |> Item.partitionByFilter ["Fluid", "Oxygen"]
        |> Expect.equal ([air], [fire, water, earth])