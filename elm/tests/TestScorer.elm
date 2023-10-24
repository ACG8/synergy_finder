module TestScorer exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import Item exposing (..)
import Scorer exposing (..)


testFire = "fire,reaction,-oxygen,-fuel,-heat,+heat,+smoke"
testWater = "water,fluid,-cool,+moisture"
testAir = "air,fluid,+oxygen"
testEarth = "earth,solid,-smoke,-moisture,-oxygen,+fuel"
testItemList = [Item.toItem testFire, Item.toItem testWater, Item.toItem testAir, Item.toItem testEarth]


sortByMargin =
    test "sortByMargin sorts items in descending order by score margin against another list of items" <|
        \_ ->
            Scorer.sortByMargin [Item.toItem testFire, Item.toItem testWater, Item.toItem testAir] testItemList
            |> Expect.equal [Item.toItem testFire, Item.toItem testAir, Item.toItem testWater]


sortByRemoval =
    test "sortByRemoval sorts items in ascending order by score margin against the list they come from" <|
        \_ ->
            Scorer.sortByRemoval testItemList
            |> Expect.equal [Item.toItem testWater, Item.toItem testAir, Item.toItem testFire, Item.toItem testEarth]


getSynergy =
    test "getSynergy should return product of items" <|
        \_ ->
            Scorer.getSynergy (Item.toItem testFire) (Item.toItem testEarth)
            |> Expect.equal 2


scoreMargin =
    test "scoreMargin should add up synergies" <|
        \_ ->
            testItemList
            |> Scorer.scoreMargin (Item.toItem testFire)
            |> Expect.equal 5


scoreRemoval =
    test "scoreRemoval should not synergize item with itself" <|
        \_ ->
            testItemList
            |> Scorer.scoreRemoval (Item.toItem testFire)
            |> Expect.equal 3



scoreList =
    test "scoreList should add up all synergies in list" <|
        \_ ->
            testItemList
            |> Scorer.scoreList
            |> Expect.equal 5
