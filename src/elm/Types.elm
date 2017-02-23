module Types exposing (..)

import Deployments.Types
import Aliases.Types exposing (Alias)
import Secrets.Types exposing (Secret)
import Login.Types
import Routing


type alias Model =
    { deployments : Deployments.Types.Model
    , aliases : List Alias
    , secrets : Secrets.Types.Model
    , route : Routing.Route
    , login : Login.Types.Model
    }


initialModel : Routing.Route -> Model
initialModel route =
    case route of
        Routing.DeploymentsRoute aliasName ->
            { deployments = Deployments.Types.initialModel aliasName
            , aliases = []
            , secrets = Secrets.Types.initialModel
            , route = route
            , login =
                { token = ""
                , isLoggedIn = False
                , errorMessage = ""
                , inProgress = False
                }
            }

        _ ->
            { deployments = Deployments.Types.initialModel ""
            , aliases = []
            , secrets = Secrets.Types.initialModel
            , route = route
            , login =
                { token = ""
                , isLoggedIn = False
                , errorMessage = ""
                , inProgress = False
                }
            }
