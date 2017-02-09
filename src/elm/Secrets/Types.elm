module Secrets.Types exposing (..)


type alias Model =
    { secrets : List Secret
    , token : String
    }


type alias SecretId =
    String


type alias Secret =
    { uid : SecretId
    , name : String
    , created : String
    }
