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


deleteAlias : String -> String -> Cmd Msg
deleteAlias token aliasId =
    HttpBuilder.delete ("https://api.zeit.co/now/aliases/" ++ aliasId)
        |> withHeader "Accept" "application/json"
        |> withHeader "Authorization" ("Bearer " ++ token)
        |> withExpect (Http.expectJson deleteAliasResponseDecoder)
        |> HttpBuilder.send (Delete_Alias_Response aliasId)



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
        (Decode.oneOf
            [ (Decode.field "deploymentId" Decode.string)
            , (Decode.succeed "")
            ]
        )


deleteAliasResponseDecoder : Decode.Decoder String
deleteAliasResponseDecoder =
    (Decode.field "status" Decode.string)
