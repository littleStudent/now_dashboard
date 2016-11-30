module Routing exposing (..)

import UrlParser exposing (..)


type Route
    = DeploymentsRoute
    | AliasesRoute
    | SecretsRoute
    | AboutRoute
    | LoginRoute
    | NotFoundRoute


route : Parser (Route -> a) a
route =
    oneOf
        [ map AboutRoute (s "about")
        , map DeploymentsRoute (s "")
        , map LoginRoute (s "login")
        , map DeploymentsRoute (s "deployments")
        , map AliasesRoute (s "aliases")
        , map SecretsRoute (s "secrets")
        ]



-- hashParser : Navigation.Location -> Result String Route
-- hashParser location =
--     location.hash
--         |> String.dropLeft 2
--         |> parse identity matchers
-- parser : Navigation.Parser (Result String Route)
-- parser =
--     Navigation.makeParser hashParser
-- routeFromResult : Result String Route -> String -> Route
-- routeFromResult result token =
--     case result of
--         Ok route ->
--             if String.isEmpty token then
--                 LoginRoute
--             else
--                 route
--         Err string ->
--             NotFoundRoute
