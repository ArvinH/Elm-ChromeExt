port module Main exposing (Flags, Msg(..), broadcast, selected, init, main, subscriptions, update)

{- BUG? Runtime error if I don't import Json.Decode -}

import Browser
import Model exposing (Model)
import Platform exposing ( Program )
import Platform.Cmd exposing ( Cmd )
import Platform.Sub exposing ( Sub )
import Round


-- PORTS FROM JAVASCRIPT

port selected : (Model -> msg) -> Sub msg


-- PORTS TO JAVASCRIPT


port broadcast : Model -> Cmd msg



-- MODEL


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( {
        selectedContent = flags.selectedContent,
        exrateTWD = flags.exrateTWD,
        exrateJPY = flags.exrateJPY,
        result = flags.result
     }
    , Cmd.none
    )


type Msg
    = NoOp
    | Select Model


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Select data ->
            let
                nextModel =
                    { model | result = data.selectedContent * (data.exrateTWD / data.exrateJPY) }
            in
            ( nextModel, broadcast nextModel )


subscriptions : Model -> Sub Msg
subscriptions model =
    selected (\newModels -> Select newModels)

type alias Flags =
    {
      selectedContent: Float,
      exrateTWD: Float,
      exrateJPY: Float,
      result: Float
    }


main : Program Flags Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }
