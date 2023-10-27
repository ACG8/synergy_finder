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
import Element.Events as Events
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
  , summary : Maybe SynergySummary
  }


type Page
  = WELCOME
  | APPLICATION


type alias Model =
  { current_page : Page
  , app : App
  }


csvToApp : String -> App
csvToApp csv =
  toItemList csv
  |> \items -> App [] items [] Nothing


init : () -> (Model, Cmd Msg)
init _ =
  ( { current_page = WELCOME
    , app = App [] [] [] Nothing
    }
  , Cmd.none
  )


-- UPDATE


type Msg
  = CsvRequested
  | CsvSelected File
  | CsvLoaded String
  | MoveItem Item
  | ShowSynergySummary Item


clearItem : Item -> App -> App
clearItem item app =
  { hidden = List.filter (\x -> x /= item) app.hidden
  , unselected = List.filter (\x -> x /= item) app.unselected
  , selected = List.filter (\x -> x /= item) app.selected
  , summary = Nothing
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


moveItem : Item -> App -> App
moveItem item app =
  if List.member item app.unselected
    then selectItem item app
    else unselectItem item app



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

    CsvLoaded csv ->
      ( Model APPLICATION <| csvToApp csv
      , Cmd.none
      )

    MoveItem item ->
      ( { model | app = moveItem item model.app }
      , Cmd.none
      )

    ShowSynergySummary item ->
      let old_app = model.app in
      ( { model | app =
          { old_app | summary = Just <| scoreRemovalVerbose item old_app.selected }
        }
      , Cmd.none
      )

-- STYLE


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


-- ELEMENTS


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


tableItemElement : Item -> Element Msg
tableItemElement item =
  Input.button
    [ padding 5
    , width fill
    , Events.onMouseEnter <| ShowSynergySummary item
    ]
    { onPress = Just (MoveItem item)
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
  , height <| px 500
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
  , Font.color color.darkCharcoal
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
          , view = \item -> tableItemElement item
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
          , view = \item -> tableItemElement item
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

summaryTable : String -> List (String, Int) -> Element Msg
summaryTable title scores =
  table tableAttr
  { data = scores
  , columns =
    [ { header = text title
      , width = fillPortion 3
      , view = \score -> text <| Tuple.first score
      }
    , { header = text "Synergy"
      , width = fillPortion 1
      , view = \score -> text (String.fromInt <| Tuple.second score)
      }
    ]
  }

summaryWindow : App -> Element Msg
summaryWindow app =
  row
    [ width fill
    , height fill
    , Border.width 2
    , Border.rounded 6
    , Border.color color.blue
    ]
    <| case app.summary of
      Nothing ->
        [ summaryTable "Needs" []
        , summaryTable "Offers" []
        ]

      Just summary ->
        [ summaryTable "Needs" summary.needs
        , summaryTable "Offers" summary.offers
        ]


-- PAGES

pageWelcome : Html Msg
pageWelcome =
  layout [] loadCsvButton

pageApplication : App -> Html Msg
pageApplication app =
  layout [ width fill, height fill ]
    <| column
      [ width fill
      , height fill
      , padding 5
      , spacing 10
      ]
      [ itemTables app
      , summaryWindow app
      ]

-- VIEW

view : Model -> Html Msg
view model =
  case model.current_page of
    WELCOME ->
      pageWelcome

    APPLICATION ->
      pageApplication model.app


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.none