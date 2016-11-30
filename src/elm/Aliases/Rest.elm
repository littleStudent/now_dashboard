module Aliases.Rest exposing (..)

import HttpBuilder exposing (..)
import Http exposing (..)
import Json.Decode as Decode exposing (Decoder, list, string, field, decodeString, at)
import Aliases.Messages exposing (..)
import Aliases.Types exposing (Alias)


-- HTTP


fetchAliases : String -> Cmd Msg
fetchAliases token =
    HttpBuilder.get "https://now.aliases.autcoding.com"
        |> withHeader "Accept" "application/json"
        |> withHeader "Authorization" token
        |> withExpect (Http.expectJson aliasDecoder)
        |> HttpBuilder.send Fetch_Aliases_Response



-- DECODERS


aliasDecoder : Decode.Decoder (List Alias)
aliasDecoder =
    Decode.list memberDecoder


memberDecoder : Decode.Decoder Alias
memberDecoder =
    Decode.map4 Alias
        (Decode.field "uid" Decode.string)
        (Decode.field "alias" Decode.string)
        (Decode.field "created" Decode.string)
        (Decode.field "deploymentId" Decode.string)
