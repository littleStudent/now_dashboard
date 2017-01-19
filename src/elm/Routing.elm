module Routing exposing (..)

import UrlParser exposing (..)


type Route
    = DeploymentsRoute String
    | HomeRoute
    | AliasesRoute
    | SecretsRoute
    | AboutRoute
    | LoginRoute
    | NotFoundRoute


route : Parser (Route -> a) a
route =
    oneOf
        [ map AboutRoute (s "about")
        , map HomeRoute (s "")
        , map LoginRoute (s "login")
        , map DeploymentsRoute (s "deployments" </> string)
        , map DeploymentsRoute (s "deployments/" </> string)
        , map AliasesRoute (s "aliases")
        , map SecretsRoute (s "secrets")
        ]
