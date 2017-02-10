module Secrets.List exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Secrets.Messages exposing (Msg(..))
import Secrets.Types exposing (..)
import Dict
import Date
import Date.Format
import Date.Extra


-- hello component


view : Model -> Html Msg
view model =
    div [ class "container content-container" ]
        [ nav model.secrets
        , list model
        ]


nav : List Secret -> Html Msg
nav secrets =
    div [ class "clearfix mb2 white bg-black" ]
        [ div [ class "left p2" ] [ text "" ] ]


list : Model -> Html Msg
list model =
    div [ class "p2" ]
        [ table [ class "table" ]
            [ thead []
                [ tr []
                    [ th [] [ text "secret name" ]
                    , th [] [ text "created" ]
                    , th [] [ text "" ]
                    , th [ class "hidden-md-down" ] [ text "" ]
                    ]
                ]
            , tbody []
                (List.map (secretRow model.requests) model.secrets)
            ]
        , input [ class "", placeholder "secret name", onInput Input_Secret_Name ] []
        , input [ class "", placeholder "secret value", onInput Input_Secret_Value ] []
        , button
            [ class "", onClick (Post_Secret_Request model.newSecretName model.newSecretValue) ]
            [ text "Send" ]
        ]


secretRow : Dict.Dict String SecretRequest -> Secret -> Html Msg
secretRow requests secret_ =
    tr []
        [ td [] [ text secret_.name ]
        , td []
            [ text
                (case Date.Extra.fromIsoString secret_.created of
                    Nothing ->
                        ""

                    Just val ->
                        Date.Format.format "%a, %b %d %I:%M %p" val
                )
            ]
        , td []
            [ button
                [ class "regular delete-button red"
                , onClick (Delete_Secret_Request secret_.uid)
                ]
                [ i [ class "fa fa-pencil mr1" ] [], text "delete" ]
            ]
        , td [ class "hidden-md-down", style [ ( "height", "70px" ) ] ] [ loadingSpinner secret_ requests ]
        ]


loadingSpinner : Secret -> Dict.Dict String SecretRequest -> Html Msg
loadingSpinner secret requests =
    let
        request =
            Dict.get secret.uid requests
    in
        case request of
            Nothing ->
                text ""

            Just val ->
                if val.inProgressCount > 0 then
                    spinner
                else
                    text ""


spinner : Html Msg
spinner =
    div [ class "sk-wave" ]
        [ div [ class "sk-rect sk-rect1" ] []
        , div [ class "sk-rect sk-rect2" ] []
        , div [ class "sk-rect sk-rect3" ] []
        , div [ class "sk-rect sk-rect4" ] []
        , div [ class "sk-rect sk-rect5" ] []
        ]
