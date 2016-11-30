module About.About exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)


type AboutMsg
    = Display_About


view : Html a
view =
    div
        [ class "h1" ]
        [ text ("Hello, Elm") ]
