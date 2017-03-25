module Aliases.Types exposing (..)

import Dict


type alias AliasId =
    String


type alias Model =
    { aliases : List Alias
    , token : String
    , requests : Dict.Dict String AliasRequest
    }


type alias Alias =
    { uid : AliasId
    , aliasName : String
    , created : String
    , deploymentId : String
    }


type alias AliasRequest =
    { inProgressCount : Int
    }


initialModel : Model
initialModel =
    { aliases = []
    , token = ""
    , requests = Dict.empty
    }
