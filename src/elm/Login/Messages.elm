module Login.Messages exposing (..)

import Secrets.Types exposing (Secret)
import Http exposing (..)


type Msg
    = Set_Token String
    | Login_Request
    | Login_Response String (Result Http.Error (List Secret))
