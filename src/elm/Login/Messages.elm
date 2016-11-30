module Login.Messages exposing (..)

import Http exposing (..)


type Msg
    = Set_Token String
    | Login_Request
    | Login_Response (Result Http.Error String)
