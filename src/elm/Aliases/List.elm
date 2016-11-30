module Aliases.List exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Aliases.Messages exposing (Msg(..))
import Aliases.Types exposing (Alias)
import Date
import Date.Format
import Date.Extra


-- hello component


view : List Alias -> Html Msg
view aliases =
    div [ class "container content-container" ]
        [ nav aliases
        , list aliases
        ]


nav : List Alias -> Html Msg
nav aliases =
    div [ class "clearfix mb2 white bg-black" ]
        [ div [ class "left p2" ] [ text "" ] ]


list : List Alias -> Html Msg
list aliases =
    div [ class "p2" ]
        [ table [ class "table" ]
            [ thead []
                [ tr []
                    [ th [] [ text "alias name" ]
                    , th [] [ text "deployment ID" ]
                    , th [] [ text "created" ]
                    ]
                ]
            , tbody [] (List.map aliasRow aliases)
            ]
        ]


aliasRow : Alias -> Html Msg
aliasRow alias_ =
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
        ]
