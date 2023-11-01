module Main exposing (..)

import Browser exposing (Document)
import Html exposing (Html, button, p, div)
import Html.Attributes exposing (style)
import File exposing (File)
import File.Select as Select
import File.Download as Download
import Task
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Set exposing (Set)
import Markdown exposing (..)


import Item exposing (..)
import Scorer exposing (..)
import String.Format as Format
import Examples exposing (..)

-- MAIN


main =
  Browser.document
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
  , custom_filter : String
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
  |> \items -> App [] items [] Nothing [] ""


init : () -> (Model, Cmd Msg)
init _ =
  ( { current_page = WELCOME
    , app = App [] [] [] Nothing [] ""
    }
  , Cmd.none
  )


-- UPDATE


type Msg
  = CsvRequested
  | CsvSelected File
  | CsvLoaded String
  | CsvDownloaded String
  | MoveItem Item
  | ShowSynergySummary Item
  | HideSynergySummary
  | ToggleFilter String
  | SetCustomFilter String


clearItem : Item -> App -> App
clearItem item app =
  { hidden = List.filter (\x -> x /= item) app.hidden
  , unselected = List.filter (\x -> x /= item) app.unselected
  , selected = List.filter (\x -> x /= item) app.selected
  , summary = Nothing
  , active_filters = app.active_filters
  , custom_filter = app.custom_filter
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
  let
    customFilter : List Item -> List Item
    customFilter =
      (\item -> String.contains app.custom_filter item.name)
      |> List.filter
  in

  app.hidden ++ app.unselected
  |> Item.partitionByFilter app.active_filters
  |> \partitioned_items ->
    { app
    | unselected = customFilter <| Tuple.first partitioned_items
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

    CsvDownloaded csv ->
      ( model
      , Download.string "synergy_data.csv" "text/csv" csv
      )

    MoveItem item ->
      ( { model | app = moveItem item model.app }
      , Cmd.none
      )

    ShowSynergySummary item ->
      let old_app = model.app in
      ( { model | app =
          { old_app | summary = Just <| getSynergySummary item old_app.selected }
        }
      , Cmd.none
      )

    HideSynergySummary ->
      let old_app = model.app in
      ( { model | app =
          { old_app | summary = Nothing }
        }
      , Cmd.none
      )

    SetCustomFilter new_filter ->
      let old_app = model.app in
      ( { model | app =
          { old_app | custom_filter = new_filter }
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
  , Events.onMouseLeave HideSynergySummary
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
  , padding 5
  ]


attrSidebar =
  [ height fill
  , width <| fillPortion 1
  , paddingXY 0 10
  , scrollbarY
  , Background.color color.darkCharcoal
  , Font.color color.white
  , Font.size 16
  ]

rowTableHeader : List (String, List (Attribute Msg)) -> Element Msg
rowTableHeader headers_list =
  let
    getElement (title, attributes) =
      el (attributes ++ attrTableHeader) <| text title
  in
  row [ width fill ] <|
    List.map getElement headers_list

-- ELEMENTS

tableSynergy : String -> List Item -> App -> Element Msg
tableSynergy title target_items app =
  let
    itemView item =
      Input.button
        [ padding 5
        , width fill
        , Events.onMouseEnter <| ShowSynergySummary item
        , mouseOver [ moveRight 15 ]
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
        <| text (String.fromInt <| Scorer.scoreItem item app.selected)

    synergy_bonus_column =
      { header = none
      , width = fillPortion 1
      , view = synergyView
      }
  in
    column
      attrTableBox
      [ rowTableHeader
        [ ( title
          , [ width <| fillPortion 3 ]
          )
        , ( "Synergy"
          , [ width <| fillPortion 1
            , Font.alignRight
            ]
          )
        ]
      , table attrTable
        { data = Scorer.sortBySynergy target_items app.selected
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
      [ ( title
        , [ width <| fillPortion 3 ]
        )
      , ( "Synergy"
        , [ width <| fillPortion 1
          , Font.alignRight
          ]
        )
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
        [ tableSummary " " []
        , tableSummary " " []
        ]

      Just summary ->
        [ tableSummary (summary.name ++ " Needs") summary.needs
        , tableSummary (summary.name ++ " Offers") summary.offers
        ]


sidebarFilter : App -> Element Msg
sidebarFilter app =
  let
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

    filter_box =
      Input.text [ width fill, Font.color color.darkCharcoal ]
      { onChange = SetCustomFilter
      , text = app.custom_filter
      , placeholder = Just <| Input.placeholder [] <| text "Filter Items"
      , label = Input.labelAbove [] <| text ""}
  in
  column
    attrSidebar
    [ filter_box
    , column [ height fill, width fill] buttonListTags
    , column [ height fill, width fill ] buttonListBonds
    ]


sidebarLoadCsv : Element Msg
sidebarLoadCsv =
  let
    attrButton =
      [ width fill
      , Font.center
      , Background.color color.blue
      , Element.focused [Background.color color.orange]
      , Border.color color.darkCharcoal
      , Border.rounded 6
      , Border.width 2
      , centerX
      , padding 10
      , mouseOver [ alpha 0.5 ]
      ]

    buttonLoadCsv =
      Input.button
        attrButton
        { onPress = Just CsvRequested
        , label = text "Load CSV"
        }

    buttonLoadExample name csv =
      Input.button
        attrButton
        { onPress = Just <| CsvLoaded csv
        , label = text name
        }

    buttonDownloadExample csv =
      Input.button
        []
        { onPress = Just <| CsvDownloaded csv
         , label =
            el [ clip, Border.rounded 6] <|
              image
                [ width <| px 40
                , height <| px 40
                , mouseOver [ alpha 0.5 ]
                , alignRight
                ]
                { src = "https://game-icons.net/icons/ffffff/000000/1x1/delapouite/cloud-download.png"
                , description = "Download CSV"
                }
        }
    rowExampleButtonPair name csv =
      row [ width fill ] <|
        [ buttonLoadExample name csv
        , buttonDownloadExample csv
        ]

  in
  column
    attrSidebar
    [ buttonLoadCsv
    , el [ Font.center, width fill, padding 20 ] <| text "---EXAMPLES---"
    , rowExampleButtonPair "Blood on the Clocktower" Examples.botc
    , rowExampleButtonPair "Spirit Island" Examples.spirit_island
    , rowExampleButtonPair "Duelyst 2" Examples.duelyst2
    ]


-- PAGES

pageWelcome : Html Msg
pageWelcome =
  layout [ width fill, height fill ] <|
    row [width fill, height fill] <|
      [ sidebarLoadCsv
      , textColumn
        [ width <| fillPortion 4
        , padding 20
        , spacing 20
        ]
        ( List.map ( \string -> paragraph [] [ text string ] ) instructions )
      ]

pageApplication : App -> Html Msg
pageApplication app =
  layout [ width fill, height fill ]
    <| row [ width fill , height fill ]
    <|
      [ sidebarFilter app
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

view : Model -> Document Msg
view model =
  let
    html =
      case model.current_page of
        WELCOME ->
          pageWelcome

        APPLICATION ->
          pageApplication <| filterItems model.app
  in
  { title = "Synergy Finder"
  , body = [ html ]
  }


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.none


-- CONTENT

instructions =
  [ "Synergy Finder:"
  , "This web app is intended to help find synergies between different items when building a list of items."
  , "In many tabletop and video games, players build a list of game components that synergize. Synergy Finder helps uncover links between different items when making such lists."
  , "Example use cases:"
  , "- TCGs like Pokemon, Yugioh, and Magic require players to build decks of cards before playing"
  , "- Script-based games like Blood on the Clocktower require the gamemaster to choose roles to include"
  , "- Many TTRPGs involve building characters by choosing from lists of traits and abilities"
  , "- Team-based games like Spirit Island often have characters that work well or poorly together"
  , "To use the app, you must provide data as a CSV file. The data that you upload must be in the form of a CSV (comma-separated value) file."
  , "Each column in the file must have a name at the top, and the leftmost column is reserved for names or identifiers of the items to be selected."
  , "Use a '+' to indicate that an attribute is an offer (something the item provides) and a '/' to indicate that it is a need (something from which the item benefits. The number of '+' or '/' symbols corresponds to the strength of the offer or need, and an item may have both an offer and the corresponding need."
  , "Note: If the app is not responsive, try disabling your browser extensions"
  ]
