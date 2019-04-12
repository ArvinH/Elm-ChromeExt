port module Main exposing (Msg(..), init, main, onState, subscriptions, update, view)

import Html exposing (Html)
import Html.Attributes
import Browser
import Model exposing (Model)



-- PORTS FROM JAVASCRIPT


port onState : (Model -> msg) -> Sub msg


init : Model -> ( Model, Cmd Msg )
init model =
    ( model
    , Cmd.none
    )


type Msg
    = NoOp
    | NewState Model


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        NewState newModel ->
            ( newModel, Cmd.none )


view : Model -> Html Msg
view model =
    Html.div
        [ Html.Attributes.class "Content"
        ]
        [     
          Html.text ("It's "),
          Html.div
            [ Html.Attributes.class "InnerContent"
            ]
            [
                Html.div [][
                    Html.text (String.fromFloat model.selectedContent)
                ],
                Html.div
                    [ Html.Attributes.class "units"
                    ]
                    [
                        Html.text (" TWD")
                    ]
            ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    onState NewState


main : Program Model Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
