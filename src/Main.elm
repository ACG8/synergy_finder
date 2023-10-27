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
import Set exposing (Set)


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
  , active_filters : List String
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
  |> \items -> App [] items [] Nothing []


init : () -> (Model, Cmd Msg)
init _ =
  ( { current_page = WELCOME
    , app = App [] [] [] Nothing []
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
  | ToggleFilter String


clearItem : Item -> App -> App
clearItem item app =
  { hidden = List.filter (\x -> x /= item) app.hidden
  , unselected = List.filter (\x -> x /= item) app.unselected
  , selected = List.filter (\x -> x /= item) app.selected
  , summary = Nothing
  , active_filters = app.active_filters
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


filterItems : App -> App
filterItems app =
  app.hidden ++ app.unselected
  |> Item.partitionByFilter app.active_filters
  |> \partitioned_items ->
    { app
    | unselected = Tuple.first partitioned_items
    , hidden = Tuple.second partitioned_items
    }


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

    ToggleFilter tag ->
      let
        app = model.app

        appWithoutTag =
          { app | active_filters = List.filter ((/=) tag ) app.active_filters }

        appWithTag =
          { app | active_filters = tag :: app.active_filters }


      in
      if List.member tag app.active_filters
        then ( { model | app = appWithoutTag }, Cmd.none )
        else ( { model | app = appWithTag }, Cmd.none )

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

attrTableBox =
  [ width fill
  , height fill
  , Border.width 2
  , Border.rounded 6
  , Border.color color.blue
  ]

attrTable =
  [ height fill
  , width <| fillPortion 1
  , Background.color <| color.lightBlue
  , Font.color <| color.darkCharcoal
  , Font.size 16
  , Border.width 5
  , padding 10
  , scrollbarY
  ]

attrTableHeader =
  [ Font.bold
  , Font.color color.darkCharcoal
  , Border.widthEach { bottom = 2, top = 0, left = 0, right = 0 }
  , Border.color color.blue
  ]

rowTableHeader : List (String, Int) -> Element Msg
rowTableHeader headers_list =
  let
    getElement (title, portion) =
      el (( width <| fillPortion portion ) :: attrTableHeader) <| text title
  in
  row [ width fill ] <|
    List.map getElement headers_list

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


tableSynergy : String -> List Item -> App -> Element Msg
tableSynergy title target_items app =
  let
    itemView item =
      Input.button
        [ padding 5
        , width fill
        , Events.onMouseEnter <| ShowSynergySummary item
        ]
        { onPress = Just (MoveItem item)
        , label = text item.name
        }

    item_name_column =
      { header = none
      , width = fillPortion 3
      , view = itemView
      }

    synergyView item =
      el
        [ padding 5
        , Font.alignRight
        ]
        <| text (String.fromInt <| Scorer.scoreRemoval item app.selected)

    synergy_bonus_column =
      { header = none
      , width = fillPortion 1
      , view = synergyView
      }
  in
    column
      attrTableBox
      [ rowTableHeader
        [ (title, 3)
        , ("Synergy", 1)
        ]
      , table attrTable
        { data = Scorer.sortByMargin target_items app.selected
        , columns = [ item_name_column, synergy_bonus_column ]
        }
      ]


itemTables : App -> Element Msg
itemTables app =
  row
    [ height <| fillPortion 2
    , width fill
    ]
    [ tableSynergy "Unselected" app.unselected app
    , tableSynergy "Selected" app.selected app
    ]


tableSummary : String -> List (String, Int) -> Element Msg
tableSummary title scores =
  let
    description_column =
      { header = none
      , width = fillPortion 3
      , view = \score -> text <| Tuple.first score
      }

    score_column =
      { header = none
      , width = fillPortion 1
      , view = \score -> el [ Font.alignRight ] <| text (String.fromInt <| Tuple.second score)
      }
  in
  column
    attrTableBox
    [ rowTableHeader
      [ (title, 3)
      , ("Synergy", 1)
      ]
    , table attrTable
      { data = scores
      , columns = [ description_column, score_column ]
      }
    ]


summaryWindow : App -> Element Msg
summaryWindow app =
  row
    [ width fill
    , height <| fillPortion 1
    ]
    <| case app.summary of
      Nothing ->
        [ tableSummary "Needs" []
        , tableSummary "Offers" []
        ]

      Just summary ->
        [ tableSummary "Needs" summary.needs
        , tableSummary "Offers" summary.offers
        ]


filterBar : App -> Element Msg
filterBar app =
  let
    attrfilterBar =
      [ height fill
      , width <| fillPortion 1
      , paddingXY 0 10
      , scrollbarY
      , Background.color color.darkCharcoal
      , Font.color color.white
      , Font.size 16
      ]

    attrButtonExtra tag =
      if List.member tag app.active_filters
        then [ Background.color color.orange ]
        else []

    attrButton tag =
      [ padding 5, width fill ]
      |> (++) (attrButtonExtra tag)


    tagButton filter_key =
      Input.button
        (attrButton filter_key)
        { onPress = Just (ToggleFilter filter_key)
        , label = text filter_key
        }

    item_filter =
      app.unselected ++ app.hidden
      |> Item.listToItemFilter

    buttonListTags =
      item_filter.tags
      |> Set.toList
      |> List.map tagButton

    buttonListBonds =
      item_filter.bonds
      |> Set.toList
      |> List.map tagButton
  in
  column
    attrfilterBar
    [ column [ height fill ] buttonListTags
    , column [ height fill ] buttonListBonds
    ]


-- PAGES

pageWelcome : Html Msg
pageWelcome =
  layout [] loadCsvButton

pageApplication : App -> Html Msg
pageApplication app =
  layout [ width fill, height fill ]
    <| row [ width fill , height fill ]
    <|
      [ filterBar app
      , column
        [ width <| fillPortion 4
        , height fill
        , padding 5
        , spacing 10
        ]
        [ itemTables app
        , summaryWindow app
        ]
      ]

-- VIEW

view : Model -> Html Msg
view model =
  case model.current_page of
    WELCOME ->
      pageWelcome

    APPLICATION ->
      pageApplication <| filterItems model.app


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.none