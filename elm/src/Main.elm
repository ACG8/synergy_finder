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
  |> (\old -> { old | unselected = Scorer.sortByMargin (item :: old.unselected) old.selected})


selectItem : Item -> App -> App
selectItem item app =
  clearItem item app
  |> (\old -> { old | selected = Scorer.sortByRemoval (item :: old.selected)})



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
blue = Element.rgb255 238 238 238
purple = Element.rgb255 238 238 100

loadCsvButton
  = Input.button
    [ Background.color blue
    , Element.focused [Background.color purple]
    , centerX
    , centerY
    , padding 30
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


tableAttr =
  [ height fill
  , width <| fillPortion 1
  , Background.color <| rgb255 92 99 118
  , Font.color <| rgb255 255 255 255
  , Border.width 5
  , padding 10
  ]


unselectedItemTable : App -> Element Msg
unselectedItemTable app =
  table
    tableAttr
    { data = app.unselected
    , columns =
      [ { header = text "Unselected"
        , width = fillPortion 3
        , view = \item -> tableItemElement item selectItem
        }
      , { header = text "Synergy"
        , width = fillPortion 1
        , view = \item -> tableScoreElement item app
        }

      ]
    }


selectedItemTable : App -> Element Msg
selectedItemTable app =
  table
    tableAttr
    { data = app.selected
    , columns =
      [ { header = text "Selected"
        , width = fillPortion 3
        , view = \item -> tableItemElement item unselectItem
        }
      , { header =
          "Synergy ({{ score }})"
          |> Format.namedValue "score"
            (String.fromInt <| Scorer.scoreList app.selected)
          |> text
        , width = fillPortion 1
        , view = \item -> tableScoreElement item app
        }

      ]
    }


-- VIEW




itemListPanel : String -> List Item -> (Item -> App -> App) -> App ->  Element Msg
itemListPanel title item_list click_method app =
  let
    activeAttrs =
      [ Background.color <| rgb255 117 179 201, Font.bold ]

    attrs =
      [ paddingXY 15 5
      , spacing 5
      , Border.width 1
      , width fill
      ]

  in
  table
    [ height fill
    , width <| fillPortion 1
    , Background.color <| rgb255 92 99 118
    , Font.color <| rgb255 255 255 255
    , Border.width 5
    , padding 10
    ]
    <|
      { data = item_list
      , columns =
        [ { header = text title
          , width = fillPortion 3
          , view = \item -> tableItemElement item click_method
          }
        , { header = text "Synergy"
          , width = fillPortion 1
          , view = \item -> tableScoreElement item app
          }

        ]
      }


view : Model -> Html Msg
view model =
  case model of
    Nothing ->
      layout [] <| loadCsvButton
    Just app ->
      layout [] <|
        row [ height fill, width fill ]
            [ unselectedItemTable app
            , selectedItemTable app
            ]


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.none