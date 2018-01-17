module Login.Messages exposing (..)

import Http exposing (..)
import Login.Types exposing (RegistrationResponse)


type Msg
    = Set_Email String
    | Registration_Request
    | Registration_Response (Result Http.Error RegistrationResponse)
    | Verification_Request
    | Verification_Response (Result Http.Error String)
