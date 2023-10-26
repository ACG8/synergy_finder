module Main exposing (..)

import Browser
import Html exposing (Html, button, p, div)
import Html.Attributes exposing (style)
import File exposing (File)
import File.Select as Select
import Task
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (..)
import Element.Font as Font
import Element.Input as Input

import Item exposing (..)
import Scorer exposing (..)
import String.Format as Format

-- MAIN


main =
  Browser.element
    { init = init
    , update = update
    , view = view
    , subscriptions = subscriptions
    }


-- MODEL

type alias App =
  { hidden : List Item
  , unselected : List Item
  , selected : List Item
  }

type alias Model = Maybe App


toModel : String -> Model
toModel csv =
  toItemList csv
  |> \xs ->
    Just
      { hidden = []
      , unselected = xs
      , selected = []
      }


init : () -> (Model, Cmd Msg)
init _ = (Nothing, Cmd.none)


-- UPDATE


type Msg
  = CsvRequested
  | CsvSelected File
  | CsvLoaded String
  | Execute (App -> App)


clearItem : Item -> App -> App
clearItem item app =
  { hidden = List.filter (\x -> x /= item) app.hidden
  , unselected = List.filter (\x -> x /= item) app.unselected
  , selected = List.filter (\x -> x /= item) app.selected
  }


hideItem : Item -> App -> App
hideItem item app =
  clearItem item app
  |> (\old -> { old | hidden = item :: old.hidden})


unselectItem : Item -> App -> App
unselectItem item app =
  clearItem item app
  |> (\old -> { old | unselected = item :: old.unselected })


selectItem : Item -> App -> App
selectItem item app =
  clearItem item app
  |> (\old -> { old | selected = item :: old.selected })



update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    CsvRequested ->
      ( model
      , Select.file ["text/csv"] CsvSelected
      )

    CsvSelected file ->
      ( model
      , Task.perform CsvLoaded (File.toString file)
      )

    CsvLoaded content ->
      ( toModel content
      , Cmd.none
      )

    Execute click_method ->
      case model of
        Nothing ->
          (Nothing, Cmd.none)

        Just app ->
          ( Just (click_method app)
          , Cmd.none
          )


-- ELEMENTS

color =
    { blue = rgb255 0x72 0x9F 0xCF
    , darkCharcoal = rgb255 0x2E 0x34 0x36
    , green = rgb255 0x20 0xBF 0x55
    , lightBlue = rgb255 0xC5 0xE8 0xF7
    , lightGrey = rgb255 0xE0 0xE0 0xE0
    , orange = rgb255 0xF2 0x64 0x19
    , red = rgb255 0xAA 0x00 0x00
    , white = rgb255 0xFF 0xFF 0xFF
    }

loadCsvButton
  = Input.button
    [ Background.color color.blue
    , Element.focused [Background.color color.orange]
    , centerX
    , centerY
    , padding 30
    , Border.width 2
    , Border.rounded 6
    , Border.color color.blue
    ]
    { onPress = Just CsvRequested
    , label = text "Load CSV"
    }


tableItemElement : Item -> (Item -> App -> App) -> Element Msg
tableItemElement item click_method =
  Input.button
    [ padding 5
    , width fill
    ]
    { onPress = Just (Execute (click_method item))
    , label = text item.name
    }


tableScoreElement : Item -> App -> Element Msg
tableScoreElement item app =
  el
    [ padding 5
    , alignRight
    ]
    <| text (String.fromInt <| Scorer.scoreRemoval item app.selected)

tableBoxAttr =
  [ width fill
  , height <| px 600
  , Border.width 2
  , Border.rounded 6
  , Border.color color.blue
  ]

tableAttr =
  [ height fill
  , width <| fillPortion 1
  , Background.color <| color.lightBlue
  , Font.color <| color.darkCharcoal
  , Border.width 5
  , padding 10
  , scrollbarY
  ]

tableHeaderAttr =
  [ Font.bold
  , Font.color color.green
  , Border.widthEach { bottom = 2, top = 0, left = 0, right = 0 }
  , Border.color color.blue
  ]


unselectedItemTable : App -> Element Msg
unselectedItemTable app =
  column tableBoxAttr
    [ row [ width fill ] <|
      [ el (( width <| fillPortion 3 ) :: tableHeaderAttr ) <| text "Unselected"
      , el (( width <| fillPortion 1 ) :: tableHeaderAttr ) <| text "Synergy" ]
    , table tableAttr
      { data = Scorer.sortByMargin app.unselected app.selected
      , columns =
        [ { header = none
          , width = fillPortion 3
          , view = \item -> tableItemElement item selectItem
          }
        , { header = none
          , width = fillPortion 1
          , view = \item -> tableScoreElement item app
          }

        ]
      }
    ]


selectedItemTable : App -> Element Msg
selectedItemTable app =
  column tableBoxAttr
    [ row [ width fill ] <|
      [ el (( width <| fillPortion 3 ) :: tableHeaderAttr ) <| text "Selected"
      , el (( width <| fillPortion 1 ) :: tableHeaderAttr ) <|
        ("Synergy ({{ score }})"
                |> Format.namedValue "score"
                  (String.fromInt <| Scorer.scoreList app.selected)
                |> text )
      ]
    , table tableAttr
      { data = Scorer.sortByRemoval app.selected
      , columns =
        [ { header = none
          , width = fillPortion 3
          , view = \item -> tableItemElement item unselectItem
          }
        , { header = none
          , width = fillPortion 1
          , view = \item -> tableScoreElement item app
          }

        ]
      }
    ]

itemTables : App -> Element Msg
itemTables app =
  row
    [ height <| fillPortion 2
    , width fill
    ]
    [ unselectedItemTable app
    , selectedItemTable app
    ]


-- VIEW


view : Model -> Html Msg
view model =
  case model of
    Nothing ->
      layout [] <| loadCsvButton
    Just app ->
      layout [ width fill, height fill ]
        <| column
          [ width fill, height fill, padding 10, spacing 10 ]
          [ itemTables app
          , el [width fill, height fill] <| text "foo"
          ]


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.none