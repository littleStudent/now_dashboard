module Secrets.List exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Secrets.Messages exposing (Msg(..))
import Secrets.Types exposing (Secret)
import Date
import Date.Format
import Date.Extra


-- hello component


view : List Secret -> Html Msg
view secrets =
    div [ class "container content-container" ]
        [ nav secrets
        , list secrets
        ]


nav : List Secret -> Html Msg
nav secrets =
    div [ class "clearfix mb2 white bg-black" ]
        [ div [ class "left p2" ] [ text "" ] ]


list : List Secret -> Html Msg
list secrets =
    div [ class "p2" ]
        [ table [ class "table" ]
            [ thead []
                [ tr []
                    [ th [] [ text "secret name" ]
                    , th [] [ text "created" ]
                    ]
                ]
            , tbody [] (List.map secretRow secrets)
            ]
        ]


secretRow : Secret -> Html Msg
secretRow secret_ =
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
        ]
