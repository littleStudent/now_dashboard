module Login.Types exposing (..)


type alias Model =
    { isLoggedIn : Bool
    , token : String
    , inProgress : Bool
    , errorMessage : String
    }
