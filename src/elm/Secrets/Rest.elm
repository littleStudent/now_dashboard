module Secrets.Rest exposing (..)

import HttpBuilder exposing (..)
import Http exposing (..)
import Json.Decode as Decode exposing (Decoder, list, string, field, decodeString, at)
import Secrets.Messages exposing (..)
import Secrets.Types exposing (Secret)


-- HTTP


fetchSecrets : String -> Cmd Msg
fetchSecrets token =
    HttpBuilder.get "https://now.secrets.autcoding.com"
        |> withHeader "Accept" "application/json"
        |> withHeader "Authorization" token
        |> withExpect (Http.expectJson aliasDecoder)
        |> HttpBuilder.send Fetch_Secrets_Response



-- DECODERS


aliasDecoder : Decode.Decoder (List Secret)
aliasDecoder =
    Decode.list memberDecoder


memberDecoder : Decode.Decoder Secret
memberDecoder =
    Decode.map3 Secret
        (Decode.field "uid" Decode.string)
        (Decode.field "name" Decode.string)
        (Decode.field "created" Decode.string)
