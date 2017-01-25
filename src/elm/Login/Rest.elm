module Login.Rest exposing (..)

import HttpBuilder exposing (..)
import Http exposing (..)
import Json.Decode as Decode exposing (Decoder, list, string, field, decodeString, at)
import Login.Messages exposing (..)
import Secrets.Types exposing (Secret)


-- HTTP


authenticate : String -> Cmd Msg
authenticate token =
    HttpBuilder.get "https://api.zeit.co/now/secrets"
        |> withHeader "Accept" "application/json"
        |> withHeader "Authorization" ("Bearer " ++ token)
        |> withExpect (Http.expectJson secretsDecoder)
        |> HttpBuilder.send (Login_Response token)



-- DECODERS


secretsDecoder : Decode.Decoder (List Secret)
secretsDecoder =
    Decode.field "secrets" secretDecoder


secretDecoder : Decode.Decoder (List Secret)
secretDecoder =
    Decode.list memberDecoder


memberDecoder : Decode.Decoder Secret
memberDecoder =
    Decode.map3 Secret
        (Decode.field "uid" Decode.string)
        (Decode.field "name" Decode.string)
        (Decode.field "created" Decode.string)
