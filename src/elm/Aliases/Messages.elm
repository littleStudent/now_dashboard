module Aliases.Messages exposing (..)

import Http exposing (..)
import Aliases.Types exposing (Alias, AliasId)


type Msg
    = Fetch_Aliases_Response (Result Http.Error (List Alias))
    | Delete_Alias_Request AliasId
    | Delete_Alias_Response AliasId (Result Http.Error String)
