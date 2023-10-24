module TestMain exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import Main exposing (..)

testCsv = """fire,reaction,-oxygen,-fuel,+heat,+smoke
water,fluid,-cool,+moisture,,
air,fluid,+oxygen,,,
earth,solid,-smoke,-moisture,-oxygen,+fuel"""