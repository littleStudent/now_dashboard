module Aliases.List exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Aliases.Messages exposing (Msg(..))
import Aliases.Types exposing (Model, Alias, AliasRequest)
import Date
import Date.Format
import Date.Extra
import Dict


-- hello component


view : Model -> Html Msg
view model =
    div [ class "container content-container" ]
        [ nav model.aliases
        , list model.aliases model.requests
        ]


nav : List Alias -> Html Msg
nav aliases =
    div [ class "clearfix mb2 white bg-black" ]
        [ div [ class "left p2" ] [ text "" ] ]


list : List Alias -> Dict.Dict String AliasRequest -> Html Msg
list aliases requests =
    div [ class "p2" ]
        [ table [ class "table" ]
            [ thead []
                [ tr []
                    [ th [] [ text "alias name" ]
                    , th [] [ text "deployment ID" ]
                    , th [] [ text "created" ]
                    , th [] [ text "actions" ]
                    , th [ class "hidden-md-down" ] [ text "" ]
                    ]
                ]
            , tbody [] (List.map (aliasRow requests) aliases)
            ]
        ]


aliasRow : Dict.Dict String AliasRequest -> Alias -> Html Msg
aliasRow requests alias_ =
    tr []
        [ td [] [ text alias_.aliasName ]
        , td [] [ text alias_.deploymentId ]
        , td []
            [ text
                (case Date.Extra.fromIsoString alias_.created of
                    Nothing ->
                        ""

                    Just val ->
                        Date.Format.format "%a, %b %d %I:%M %p" val
                )
            ]
        , actions alias_
        , td [ class "hidden-md-down", style [ ( "height", "70px" ) ] ] [ loadingSpinner alias_ requests ]
        ]


loadingSpinner : Alias -> Dict.Dict String AliasRequest -> Html Msg
loadingSpinner deployment requests =
    let
        request =
            Dict.get deployment.uid requests
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


actions : Alias -> Html Msg
actions alias_ =
    td [ class "flex-single-column" ]
        [ button
            [ class "regular delete-button red"
            , onClick (Delete_Alias_Request alias_.uid)
            ]
            [ i [ class "fa fa-pencil mr1" ] [], text "delete" ]
        ]
