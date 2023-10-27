module TestItem exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import Item exposing (..)
import Scorer exposing (..)


testCsv = """fire,reaction,element,-oxygen,-fuel,-heat,+heat,+smoke
water,fluid,element,-cool,+moisture,,
air,fluid,element,+oxygen,,,
earth,solid,element,-smoke,-moisture,-oxygen,+fuel
oil,fluid"""


testFire = "fire,reaction,element,-oxygen,-fuel,-heat,+heat,+smoke"

toItem =
    test "item should be fire" <|
        \_ -> Item.toItem testFire
            |> Expect.equal
                ( Just
                    { name = "fire"
                    , tags = ["reaction", "element"]
                    , needs = ["oxygen", "fuel", "heat"]
                    , offers = ["heat", "smoke"]
                    }
                )



toItemList =
    test "item list should contain correct items" <|
        \_ -> Item.toItemList testCsv
            |> Expect.equal
                [ { name = "fire"
                  , tags = ["reaction", "element"]
                  , needs = ["oxygen", "fuel", "heat"]
                  , offers = ["heat", "smoke"]
                }
                , { name = "water"
                  , tags = ["fluid", "element"]
                  , needs = ["cool"]
                  , offers = ["moisture"]
                }
                , { name = "air"
                  , tags = ["fluid", "element"]
                  , needs = []
                  , offers = ["oxygen"]
                }
                , { name = "earth"
                  , tags = ["solid", "element"]
                  , needs = ["smoke", "moisture", "oxygen"]
                  , offers = ["fuel"]
                }
                , Item "oil" ["fluid"] [] []
                ]

partitionByTags =
    let
        fire = Item "fire" ["reaction", "element"] ["oxygen", "fuel", "heat"] ["heat", "smoke"]

        water = Item "water" ["fluid", "element"] ["cool"] ["moisture"]

        air = Item "air" ["fluid", "element"] [] ["oxygen"]

        earth = Item "earth" ["solid", "element"] ["smoke", "moisture", "oxygen"] ["fuel"]

        oil = Item "oil" ["fluid"] [] []
    in
    test "item list should be split into items with ALL tags and items without" <|
    \_ ->

        Item.toItemList testCsv
        |> Item.partitionByTags ["fluid", "element"]
        |> Expect.equal ([water, air], [fire, earth, oil])