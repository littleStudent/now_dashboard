module Aliases.Rest exposing (..)

import HttpBuilder exposing (..)
import Http exposing (..)
import Json.Decode as Decode exposing (Decoder, list, string, field, decodeString, at)
import Aliases.Messages exposing (..)
import Aliases.Types exposing (Alias)


-- HTTP


fetchAliases : String -> Cmd Msg
fetchAliases token =
    HttpBuilder.get "https://api.zeit.co/now/aliases"
        |> withHeader "Accept" "application/json"
        |> withHeader "Authorization" ("Bearer " ++ token)
        |> withExpect (Http.expectJson aliasesDecoder)
        |> HttpBuilder.send Fetch_Aliases_Response



-- DECODERS


aliasesDecoder : Decode.Decoder (List Alias)
aliasesDecoder =
    Decode.field "aliases" aliasDecoder


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
