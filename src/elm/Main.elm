port module Main exposing (..)

import Navigation
import Messages exposing (Msg(..))
import Types exposing (Model, initialModel)
import View exposing (view)
import State exposing (update)
import Routing exposing (Route(..))
import Ports exposing (..)
import UrlParser exposing (..)


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    let
        currentRoute =
            parser location
    in
        case currentRoute of
            GoTo url ->
                case url of
                    Nothing ->
                        ( initialModel (Routing.DeploymentsRoute ""), startLoadToken () )

                    Just val ->
                        case val of
                            HomeRoute ->
                                ( initialModel (Routing.DeploymentsRoute "")
                                , Cmd.batch
                                    [ Navigation.newUrl "/deployments"
                                    , startLoadToken ()
                                    ]
                                )

                            _ ->
                                ( initialModel val, startLoadToken () )

            _ ->
                ( initialModel Routing.LoginRoute, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    loadedToken Load_Token


main : Program Never Model Msg
main =
    Navigation.program parser
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


parser : Navigation.Location -> Msg
parser location =
    GoTo (parsePath Routing.route location)
