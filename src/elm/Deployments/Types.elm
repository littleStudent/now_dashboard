module Deployments.Types exposing (..)

import Aliases.Types exposing (Alias)
import Deployments.Autocomplete
import Dict


type alias Model =
    { deployments : List Deployment
    , aliases : List Alias
    , selectedAliasName : String
    , token : String
    , editMode : Dict.Dict String EditMode
    , autocompleteMode : Dict.Dict String Deployments.Autocomplete.Model
    , requests : Dict.Dict String DeploymentRequest
    }


type alias EditMode =
    { aliasName : String
    , successMessage : String
    , errorMessage : String
    }


type alias DeploymentRequest =
    { inProgressCount : Int
    }


initialModel : String -> Model
initialModel aliasName =
    { deployments = []
    , aliases = []
    , selectedAliasName = aliasName
    , token = ""
    , autocompleteMode = Dict.empty
    , editMode = Dict.empty
    , requests = Dict.empty
    }


type alias DeploymentId =
    String


type alias Deployment =
    { uid : String
    , name : String
    , url : String
    , created : String
    , state : Maybe String
    }


type alias DeploymentState =
    { uid : String
    , host : Maybe String
    , state : String
    }


type alias SetAliasResponse =
    { oldId : String
    , uid : String
    , created : String
    }
