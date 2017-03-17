port module Ports exposing (..)


port scrollTo : String -> Cmd msg


port trackPage : String -> Cmd msg


port setToken : String -> Cmd msg


port loadedToken : (String -> msg) -> Sub msg


port startLoadToken : () -> Cmd msg
