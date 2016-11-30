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
        case Debug.log "init" currentRoute of
            GoTo url ->
                case url of
                    Nothing ->
                        ( initialModel Routing.DeploymentsRoute, startLoadToken () )

                    Just val ->
                        case val of
                            DeploymentsRoute ->
                                ( initialModel Routing.DeploymentsRoute, startLoadToken () )

                            AliasesRoute ->
                                ( initialModel Routing.DeploymentsRoute, startLoadToken () )

                            SecretsRoute ->
                                ( initialModel Routing.DeploymentsRoute, startLoadToken () )

                            AboutRoute ->
                                ( initialModel Routing.DeploymentsRoute, startLoadToken () )

                            LoginRoute ->
                                ( initialModel Routing.DeploymentsRoute, startLoadToken () )

                            NotFoundRoute ->
                                ( initialModel Routing.DeploymentsRoute, Cmd.none )

            _ ->
                ( initialModel Routing.DeploymentsRoute, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    loadedToken Load_Token



-- urlUpdate : Result String Route -> Model -> ( Model, Cmd Msg )
-- urlUpdate result model =
--     let
--         currentRoute =
--             Routing.routeFromResult result model.login.token
--     in
--         case currentRoute of
--             DeploymentsRoute ->
--                 if model.login.isLoggedIn then
--                     ( { model | route = currentRoute }, Cmd.map DeploymentsMsg (fetchDeployments model.login.token) )
--                 else
--                     ( model, Navigation.newUrl "/#/login" )
--             AliasesRoute ->
--                 if model.login.isLoggedIn then
--                     ( { model | route = currentRoute }, Cmd.map AliasesMsg (fetchAliases model.login.token) )
--                 else
--                     ( model, Navigation.newUrl "/#/login" )
--             SecretsRoute ->
--                 if model.login.isLoggedIn then
--                     ( { model | route = currentRoute }, Cmd.map SecretsMsg (fetchSecrets model.login.token) )
--                 else
--                     ( model, Navigation.newUrl "/#/login" )
--             AboutRoute ->
--                 ( { model | route = currentRoute }, Cmd.none )
--             LoginRoute ->
--                 if model.login.isLoggedIn then
--                     ( model, Navigation.newUrl "/#/deployments" )
--                 else
--                     ( { model | route = currentRoute }, Cmd.none )
--             NotFoundRoute ->
--                 ( { model | route = currentRoute }, Cmd.none )


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
    let
        _ =
            Debug.log "location" location
    in
        GoTo (parseHash Routing.route location)
