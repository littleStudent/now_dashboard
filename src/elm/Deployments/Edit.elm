module Deployments.Edit exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Deployments.Types exposing (Deployment)


-- hello component


view : Deployment -> Html a
view model =
    div
        [ class "h1" ]
        [ text ("Hello, Elm") ]
