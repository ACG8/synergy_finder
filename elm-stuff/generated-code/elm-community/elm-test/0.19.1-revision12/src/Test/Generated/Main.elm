module Test.Generated.Main exposing (main)

import TestItem

import Test.Reporter.Reporter exposing (Report(..))
import Console.Text exposing (UseColor(..))
import Test.Runner.Node
import Test

main : Test.Runner.Node.TestProgram
main =
    Test.Runner.Node.run
        { runs = 100
        , report = ConsoleReport Monochrome
        , seed = 183609930830771
        , processes = 8
        , globs =
            [ "tests/TestItem.elm"
            ]
        , paths =
            [ "E:\\GitHub\\synergy_finder\\tests\\TestItem.elm"
            ]
        }
        [ ( "TestItem"
          , [ Test.Runner.Node.check TestItem.testCsv
            , Test.Runner.Node.check TestItem.toItemList
            , Test.Runner.Node.check TestItem.listToItemFilter
            , Test.Runner.Node.check TestItem.getTagsFromList
            , Test.Runner.Node.check TestItem.partitionByFilter
            ]
          )
        ]