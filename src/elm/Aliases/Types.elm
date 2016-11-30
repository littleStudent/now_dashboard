module Aliases.Types exposing (..)


type alias AliasId =
    String


type alias Alias =
    { uid : AliasId
    , aliasName : String
    , created : String
    , deploymentId : String
    }
