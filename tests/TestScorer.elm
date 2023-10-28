module TestScorer exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import Item exposing (..)
import Scorer exposing (..)


testFire = Item "Fire" ["Reaction", "Element"] [("Oxygen", 1), ("Fuel", 2), ("Heat", 1)] [("Heat", 2), ("Smoke", 2)]
testWater = Item "Water" ["Fluid", "Element"] [("Cool", 1)] [("Moisture", 3)]
testAir = Item "Air" ["Fluid", "Element"] [] [("Oxygen", 3)]
testEarth = Item "Earth" ["Solid", "Element"] [("Oxygen", 1), ("Smoke", 1), ("Moisture", 2)] [("Fuel", 1)]
testItemList = [testFire, testWater, testAir, testEarth]





sortBySynergy =
    test "sortBySynergy sorts items in descending order by score margin against another list of items" <|
        \_ ->
            Scorer.sortBySynergy [testFire, testWater, testAir] testItemList
            |> Expect.equal [testFire, testAir, testWater]


scoreItem =
    test "scoreItem should not synergize item with itself" <|
        \_ ->
            testItemList
            |> Scorer.scoreItem testFire
            |> Expect.equal (3+2+2)


getSynergySummary =
    test "getSynergySummary should list amount of points for each synergy" <|
        \_ ->
            testItemList
            |> Scorer.getSynergySummary testFire
            |> Expect.equal
                { name = "Fire"
                , needs =
                    [ ("Oxygen", 3)
                    , ("Fuel", 2)
                    , ("Heat", 0)
                    ]
                , offers =
                    [ ("Heat", 0)
                    , ("Smoke", 2)
                    ]
                }
