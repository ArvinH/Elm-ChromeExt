port module Main exposing (Flags, Msg(..), broadcast, selected, init, main, subscriptions, update)

{- BUG? Runtime error if I don't import Json.Decode -}

import Browser
import Http
import Model exposing (Model)
import Platform exposing ( Program )
import Platform.Cmd exposing ( Cmd )
import Platform.Sub exposing ( Sub )
import Json.Decode exposing (Decoder, field, string)


-- PORTS FROM JAVASCRIPT

port selected : (Model -> msg) -> Sub msg


-- PORTS TO JAVASCRIPT


port broadcast : Model -> Cmd msg



-- MODEL

type Result error value
  = Ok value
  | Err error

init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { selectedContent = flags.selectedContent, currencyRateData = {} }
    , Http.get
      { url = "https://tw.rter.info/capi.php"
      , expect = Http.expectJson GotData
      }
    )

type Msg
    = NoOp
    | Select Model
    | GotData (Result Http.Error {})


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        GotData result ->
            case result of
                Ok resultData ->
                    let
                        nextModel =
                            { model | currencyRateData = resultData }
                    in
                    ( nextModel, broadcast nextModel )
                Err _ ->
                    (model, Cmd.none)


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
    {
      selectedContent: String
    }


main : Program Flags Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }
