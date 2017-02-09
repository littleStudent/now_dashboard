module Secrets.Messages exposing (..)

import Http exposing (..)
import Secrets.Types exposing (Secret)


type Msg
    = Fetch_Secrets_Response (Result Http.Error (List Secret))
    | Delete_Secret_Request String
    | Delete_Secret_Response (Result Http.Error String)
