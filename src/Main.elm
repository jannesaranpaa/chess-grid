module Main exposing (main)

import Browser

import Html
import Html.Attributes as Attr
import Html.Events as Events

import Random

import Material.Icons as Filled
import Material.Icons.Types exposing (Coloring(..))

import Time

-- MAIN

main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }

-- MODEL

type GameStatus
    = Pending
    | Running

type Side
    = White
    | Black

type alias Options =
    { showCoordinates : Bool
    , showLabels : Bool
    , side : Side
    }

initOptions : Options
initOptions =
    { showCoordinates = False
    , showLabels = True
    , side = White
    }

type alias Model =
    { moves : Int
    , target : String
    , status : GameStatus
    , optionsOpen : Bool
    , options : Options
    , time : Time.Posix
    , startTime : Time.Posix
    }

init : () -> ( Model, Cmd Msg )
init _ =
    ( { moves = 0
      , target = ""
      , status = Pending
      , optionsOpen = False
      , options = initOptions
      , time = (Time.millisToPosix 0)
      , startTime = (Time.millisToPosix 0)
      }
    , Cmd.none
    )


-- UPDATE

numToLetter : Int -> String
numToLetter n =
    if n >= 1 && n <= 8 then
        String.fromChar (Char.fromCode (Char.toCode 'a' + (n - 1)))
    else
        "?"


targetGenerator : Random.Generator String
targetGenerator =
    Random.map2
        (\x y -> numToLetter x ++ String.fromInt y)
        (Random.int 1 8)
        (Random.int 1 8)


type Msg
    = Increment
    | Reset
    | GenerateTarget
    | GotTarget String
    | StartGame
    | StopGame
    | ClickCell String
    | SetShowCoordinates Bool
    | SetShowLabels Bool
    | CloseOptions
    | OpenOptions
    | Tick Time.Posix
    | SetSide Side
    | NoOp

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Increment ->
            ( { model | moves = model.moves + 1 }, Cmd.none )

        Reset ->
            ( { model | moves = 0 }, Cmd.none )

        GenerateTarget ->
            ( model, Random.generate GotTarget targetGenerator )

        GotTarget c ->
            ( { model | target = c }, Cmd.none )

        StartGame ->
            ( { model | status = Running, moves = 0, startTime = model.time }, Random.generate GotTarget targetGenerator )

        StopGame ->
            ( { model | status = Pending, target = "" }, Cmd.none )

        ClickCell target ->
            if model.status == Running && target == model.target then
                ( { model | moves = model.moves + 1}, Random.generate GotTarget targetGenerator )
            else
                ( { model | status = Pending }, Cmd.none )

        SetShowCoordinates value ->
            let
                oldOptions = model.options
                newOptions = { oldOptions | showCoordinates = value, showLabels = if value == True then False else model.options.showLabels }
            in
            (
                { model | options = newOptions }
            , Cmd.none
            )

        SetShowLabels value ->
            let
                oldOptions = model.options
                newOptions = { oldOptions | showLabels = value, showCoordinates = if value == True then False else model.options.showCoordinates }
            in
            (
                { model | options = newOptions }
            , Cmd.none
            )

        CloseOptions ->
            ( { model | optionsOpen = False }, Cmd.none )

        OpenOptions ->
            ( { model | optionsOpen = True }, Cmd.none )

        Tick newTime ->
            ( { model | time = newTime }, Cmd.none )

        SetSide side ->
            let
                opts = model.options
                newOptions = { opts | side = side }
            in
            ( { model | options = newOptions }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions _ =
    Time.every 1000 Tick

-- VIEW

view : Model -> Html.Html Msg
view model =
    Html.div [ Attr.class "App" ]
        -- [ viewControls model.status model.target model.moves
        [ viewDisplay model.status model.target model.moves model.time model.startTime
        , viewGrid model.options
        , viewOptions model.optionsOpen model.options
        ]

viewDisplay : GameStatus -> String -> Int -> Time.Posix -> Time.Posix -> Html.Html Msg
viewDisplay status target moves time startTime =
    let
        timeMillis = Time.posixToMillis time
        startTimeMillis = Time.posixToMillis startTime
        delta = max 0 (timeMillis - startTimeMillis)
        totalSeconds = delta // 1000
        minutes = totalSeconds // 60
        seconds = remainderBy 60 totalSeconds
        timeString =
            if status == Running then
                String.padLeft 2 '0' (String.fromInt minutes) ++ ":" ++ String.padLeft 2 '0' (String.fromInt seconds)
            else
                "00:00"

    in
    Html.div
        [ Attr.class "Display" ]
        [ Html.div
            [ Attr.class "settings"
            , Events.onClick OpenOptions
            , Attr.tabindex 0
            ]
            [ Html.text (if status == Pending then "settings" else "") ]

        , Html.div [ Attr.class "status" ]
            [ if status == Running then Filled.play_arrow 16 Inherit else Filled.pause 16 Inherit ]

        , Html.div [ Attr.class "last" ]
            [ Html.text ""]

        , Html.div
            [ Attr.class "current"
            , Events.onClick (if status == Running then NoOp else StartGame)
            ]
            [ Html.text (if status == Running then target else "START") ]

        , Html.div [ Attr.class "next" ]
            [ Html.text ""]

        , Html.div [ Attr.class "time" ]
            [ Html.text timeString ]

        , Html.div [ Attr.class "moves" ]
            (
                if status == Running then
                    [ Html.text (String.fromInt moves) ]
                else
                    [ Html.text (String.fromInt moves) ]
            )
        ]

viewGrid : Options -> Html.Html Msg
viewGrid options =
    Html.div
        [ Attr.class "Grid" ]
        ( List.map (\x -> viewRow x options) (List.range 1 8) )

viewRow : Int -> Options -> Html.Html Msg
viewRow rowId options =
    Html.div
        [ Attr.class "Row" ]
        ( List.map (\x -> viewCell rowId x options) (List.range 1 8) )


viewCell : Int -> Int -> Options -> Html.Html Msg
viewCell rowId colId options =
    let
        number =
            if options.side == White then
                String.fromInt (9 - rowId)
            else
                String.fromInt rowId

        letter =
            if options.side == White then
                numToLetter colId
            else
                numToLetter (9 - colId)

        value = letter ++ number

        rowLabel =
            if rowId == 1 || rowId == 8 then
                letter
            else
                ""

        colLabel =
            if colId == 1 || colId == 8 then
                number
            else
                ""
    in
    Html.div
        [ Attr.class ("Cell _" ++ number ++ " " ++ letter ++ " side-" ++ (if options.side == White then "white" else "black"))
        , Attr.tabindex 0
        , Events.onClick (ClickCell value)
        ]
        [ Html.span
            [ Attr.class "coordinate", Attr.classList [("visible", options.showCoordinates)]]
            [ Html.text value ]
        , Html.span
            [ Attr.class "label row"]
            [ Html.text (if options.showLabels then rowLabel else "") ]
        , Html.span
            [ Attr.class "label col"]
            [ Html.text (if options.showLabels then colLabel else "") ]
        ]

viewOptions : Bool -> Options -> Html.Html Msg
viewOptions open options =
    if open == False then
        Html.div
            [ Attr.class "Options closed" ]
            []
    else
        Html.div
            [ Attr.class "Options open" ]
                [ Html.div [ Attr.class "options" ]
                    [ Html.div [ Attr.class "title" ]
                        [ Html.h3 [ Events.onClick CloseOptions ]
                            [ Html.text "Options" ]
                        , Html.button
                            [ Events.onClick CloseOptions ]
                            [ Filled.close 16 Inherit]
                        ]
                , viewToggle "Show coordinates" options.showCoordinates SetShowCoordinates
                , viewToggle "Show labels" options.showLabels SetShowLabels
                , viewToggle "Play as white" (options.side == White) (\x -> SetSide (if x == True then White else Black))
                , Html.input
                    [ Attr.type_ "button"
                    , Attr.value "Save"
                    , Events.onClick CloseOptions
                    , Attr.class "button save"
                    ]
                    []

                    ]

                , Html.div [ Attr.class "about" ]
                    [ Html.a [ Attr.href "https://github.com/jannesaranpaa/chess-grid" ]
                        [ Html.img [ Attr.src "res/github-mark-white.png", Attr.class "icon", Attr.height 16, Attr.width 16 ]
                            []
                        , Html.text " Check out chess-grid on github"
                        ]
                    , Html.p [ Attr.class "copyright" ] [ Html.text "Janne Saranpää © 2025"]
                    ]
            ]


viewToggle : String -> Bool -> (Bool -> msg) -> Html.Html msg
viewToggle label value toMsg =
    Html.label
        [ Attr.class "Toggle" ]
        [ Html.span
            [ Attr.class "label" ]
            [ Html.text label ]
        , Html.input
            [ Attr.type_ "checkbox"
            , Attr.checked value
            , Events.onCheck toMsg
            ]
            []
        ]
