module Login.Types exposing (..)


type alias Model =
    { isLoggedIn : Bool
    , registrationToken : String
    , securityCode : String
    , token : String
    , email : String
    , inProgress : Bool
    , errorMessage : String
    }


type alias RegistrationResponse =
    { token : String
    , securityCode : String
    }
