module Types exposing (..)

import Aliases.Types
import Deployments.Types
import Login.Types
import Routing
import Secrets.Types exposing (Secret)


type alias Model =
    { deployments : Deployments.Types.Model
    , aliases : Aliases.Types.Model
    , secrets : Secrets.Types.Model
    , route : Routing.Route
    , login : Login.Types.Model
    }


initialModel : Routing.Route -> Model
initialModel route =
    case route of
        Routing.DeploymentsRoute aliasName ->
            { deployments = Deployments.Types.initialModel aliasName
            , aliases = Aliases.Types.initialModel
            , secrets = Secrets.Types.initialModel
            , route = route
            , login =
                { token = ""
                , registrationToken = ""
                , securityCode = ""
                , email = ""
                , isLoggedIn = False
                , errorMessage = ""
                , inProgress = False
                }
            }

        _ ->
            { deployments = Deployments.Types.initialModel ""
            , aliases = Aliases.Types.initialModel
            , secrets = Secrets.Types.initialModel
            , route = route
            , login =
                { token = ""
                , registrationToken = ""
                , securityCode = ""
                , email = ""
                , isLoggedIn = False
                , errorMessage = ""
                , inProgress = False
                }
            }
