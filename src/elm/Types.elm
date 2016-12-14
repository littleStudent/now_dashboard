module Types exposing (..)

import Deployments.Types
import Aliases.Types exposing (Alias)
import Secrets.Types exposing (Secret)
import Login.Types
import Routing


type alias Model =
    { deployments : Deployments.Types.Model
    , aliases : List Alias
    , selectedAlias : Maybe Alias
    , secrets : List Secret
    , route : Routing.Route
    , login : Login.Types.Model
    }


initialModel : Routing.Route -> Model
initialModel route =
    { deployments = Deployments.Types.initialModel
    , aliases = []
    , selectedAlias = Nothing
    , secrets = []
    , route = route
    , login = { token = "", isLoggedIn = False, errorMessage = "" }
    }
