module Secrets.Types exposing (..)

import Dict


type alias Model =
    { secrets : List Secret
    , token : String
    , requests : Dict.Dict String SecretRequest
    , newSecretName : String
    , newSecretValue : String
    }


type alias SecretRequest =
    { inProgressCount : Int
    }


type alias SecretId =
    String


type alias Secret =
    { uid : SecretId
    , name : String
    , created : String
    }


initialModel : Model
initialModel =
    { secrets = []
    , token = ""
    , requests = Dict.empty
    , newSecretName = ""
    , newSecretValue = ""
    }
