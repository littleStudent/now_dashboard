module Aliases.Messages exposing (..)

import Http exposing (..)
import Aliases.Types exposing (Alias)


type Msg
    = Fetch_Aliases_Response (Result Http.Error (List Alias))
