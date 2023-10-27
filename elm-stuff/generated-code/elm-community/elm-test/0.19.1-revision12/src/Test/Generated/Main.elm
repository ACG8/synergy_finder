module Test.Generated.Main exposing (main)

import TestItem
import TestMain
import TestScorer

import Test.Reporter.Reporter exposing (Report(..))
import Console.Text exposing (UseColor(..))
import Test.Runner.Node
import Test

main : Test.Runner.Node.TestProgram
main =
    Test.Runner.Node.run
        { runs = 100
        , report = ConsoleReport Monochrome
        , seed = 18133593833859
        , processes = 8
        , globs =
            []
        , paths =
            [ "E:\\GitHub\\synergy_finder\\tests\\TestItem.elm"
            , "E:\\GitHub\\synergy_finder\\tests\\TestMain.elm"
            , "E:\\GitHub\\synergy_finder\\tests\\TestScorer.elm"
            ]
        }
        [ ( "TestItem"
          , [ Test.Runner.Node.check TestItem.testCsv
            , Test.Runner.Node.check TestItem.testFire
            , Test.Runner.Node.check TestItem.testWater
            , Test.Runner.Node.check TestItem.testAir
            , Test.Runner.Node.check TestItem.testEarth
            , Test.Runner.Node.check TestItem.toItem
            , Test.Runner.Node.check TestItem.toItemList
            ]
          )
        , ( "TestMain"
          , [ Test.Runner.Node.check TestMain.testCsv
            ]
          )
        , ( "TestScorer"
          , [ Test.Runner.Node.check TestScorer.testFire
            , Test.Runner.Node.check TestScorer.testWater
            , Test.Runner.Node.check TestScorer.testAir
            , Test.Runner.Node.check TestScorer.testEarth
            , Test.Runner.Node.check TestScorer.testItemList
            , Test.Runner.Node.check TestScorer.sortByMargin
            , Test.Runner.Node.check TestScorer.scoreRemoval
            , Test.Runner.Node.check TestScorer.scoreList
            , Test.Runner.Node.check TestScorer.scoreRemovalVerbose
            ]
          )
        ]