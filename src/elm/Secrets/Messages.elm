module Secrets.Messages exposing (..)

import Http exposing (..)
import Secrets.Types exposing (Secret)


type Msg
    = Fetch_Secrets_Request
    | Fetch_Secrets_Response (Result Http.Error (List Secret))
    | Delete_Secret_Request String
    | Delete_Secret_Response String (Result Http.Error String)
    | Post_Secret_Request String String
    | Post_Secret_Response String (Result Http.Error String)
    | Input_Secret_Name String
    | Input_Secret_Value String
