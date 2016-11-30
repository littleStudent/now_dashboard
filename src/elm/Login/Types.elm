module Login.Types exposing (..)


type alias Model =
    { isLoggedIn : Bool
    , token : String
    , errorMessage : String
    }
