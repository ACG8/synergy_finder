module TestItem exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import Item exposing (..)
import Scorer exposing (..)


testCsv = """fire,reaction,-oxygen,-fuel,-heat,+heat,+smoke
water,fluid,-cool,+moisture,,
air,fluid,+oxygen,,,
earth,solid,-smoke,-moisture,-oxygen,+fuel"""


testFire = "fire,reaction,-oxygen,-fuel,-heat,+heat,+smoke"
testWater = "water,fluid,-cool,+moisture"
testAir = "air,fluid,+oxygen"
testEarth = "earth,solid,-smoke,-moisture,-oxygen,+fuel"


toItem =
    test "item should be fire" <|
        \_ -> Item.toItem testFire
            |> Expect.equal
                { name = Just "fire"
                , tags = ["reaction"]
                , needs = ["oxygen", "fuel", "heat"]
                , offers = ["heat", "smoke"]
                }



toItemList =
    test "item list should contain correct items" <|
        \_ -> Item.toItemList testCsv
            |> Expect.equal
                [ { name = Just "fire"
                  , tags = ["reaction"]
                  , needs = ["oxygen", "fuel", "heat"]
                  , offers = ["heat", "smoke"]
                }
                , { name = Just "water"
                  , tags = ["fluid"]
                  , needs = ["cool"]
                  , offers = ["moisture"]
                }
                , { name = Just "air"
                  , tags = ["fluid"]
                  , needs = []
                  , offers = ["oxygen"]
                }
                , { name = Just "earth"
                  , tags = ["solid"]
                  , needs = ["smoke", "moisture", "oxygen"]
                  , offers = ["fuel"]
                }
                ]