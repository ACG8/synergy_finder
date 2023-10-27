module TestScorer exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import Item exposing (..)
import Scorer exposing (..)


testFire =
    { name = "fire"
    , tags = ["reaction"]
    , needs = ["oxygen", "fuel", "heat"]
    , offers = ["heat", "smoke"]
    }
testWater =
    { name = "water"
    , tags = ["fluid"]
    , needs = ["cool"]
    , offers = ["moisture"]
    }
testAir =
    { name = "air"
    , tags = ["fluid"]
    , needs = []
    , offers = ["oxygen"]
    }
testEarth =
    { name = "earth"
    , tags = ["solid"]
    , needs = ["smoke", "moisture", "oxygen"]
    , offers = ["fuel"]
    }
testItemList = [testFire, testWater, testAir, testEarth]


sortByMargin =
    test "sortByMargin sorts items in descending order by score margin against another list of items" <|
        \_ ->
            Scorer.sortByMargin [testFire, testWater, testAir] testItemList
            |> Expect.equal [testFire, testAir, testWater]


scoreRemoval =
    test "scoreRemoval should not synergize item with itself" <|
        \_ ->
            testItemList
            |> Scorer.scoreRemoval testFire
            |> Expect.equal 3


scoreList =
    test "scoreList should add up all synergies in list" <|
        \_ ->
            testItemList
            |> Scorer.scoreList
            |> Expect.equal 5


scoreRemovalVerbose =
    test "scoreRemovalVerbose should list amount of points for each synergy" <|
        \_ ->
            testItemList
            |> Scorer.scoreRemovalVerbose testFire
            |> Expect.equal
                { name = "fire"
                , needs =
                    [ ("oxygen", 1)
                    , ("fuel", 1)
                    , ("heat", 0)
                    ]
                , offers =
                    [ ("heat", 0)
                    , ("smoke", 1)
                    ]
                }
