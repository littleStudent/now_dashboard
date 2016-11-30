module Secrets.Types exposing (..)


type alias SecretId =
    String


type alias Secret =
    { uid : SecretId
    , name : String
    , created : String
    }
