port module Main exposing (Flags, Msg(..), broadcast, clicked, selected, init, main, subscriptions, update)

{- BUG? Runtime error if I don't import Json.Decode -}

import Browser
import Model exposing (Model)
import Platform exposing ( Program )
import Platform.Cmd exposing ( Cmd )
import Platform.Sub exposing ( Sub )



-- PORTS FROM JAVASCRIPT


port clicked : (() -> msg) -> Sub msg
port selected : (Model -> msg) -> Sub msg


-- PORTS TO JAVASCRIPT


port broadcast : Model -> Cmd msg



-- MODEL


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { clicks = flags.clicks, selectedContent = flags.selectedContent }
    , Cmd.none
    )


type Msg
    = NoOp
    | Click
    | Select Model


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Click ->
            let
                nextModel =
                    { model | clicks = model.clicks + 1 }
            in
            ( nextModel, broadcast nextModel )

        Select data ->
            let
                nextModel =
                    { model | selectedContent = data.selectedContent }
            in
            ( nextModel, broadcast nextModel )


subscriptions : Model -> Sub Msg
subscriptions model =
    selected (\newModels -> Select newModels)

type alias Flags =
    { clicks : Int,
      selectedContent: String
    }


main : Program Flags Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }
