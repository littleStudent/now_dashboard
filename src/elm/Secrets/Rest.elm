module Secrets.Rest exposing (..)

import HttpBuilder exposing (..)
import Http exposing (..)
import Json.Decode as Decode exposing (Decoder, list, string, field, decodeString, at)
import Json.Encode as Encode exposing (..)
import Secrets.Messages exposing (..)
import Secrets.Types exposing (Secret)


-- HTTP


fetchSecrets : String -> Cmd Msg
fetchSecrets token =
    HttpBuilder.get "https://api.zeit.co/now/secrets"
        |> withHeader "Accept" "application/json"
        |> withHeader "Authorization" ("Bearer " ++ token)
        |> withExpect (Http.expectJson secretsDecoder)
        |> HttpBuilder.send Fetch_Secrets_Response


deleteSecret : String -> String -> Cmd Msg
deleteSecret token secretId =
    HttpBuilder.delete ("https://api.zeit.co/now/secrets/" ++ secretId)
        |> withHeader "Accept" "application/json"
        |> withHeader "Authorization" ("Bearer " ++ token)
        |> withExpect (Http.expectJson uuidDecoder)
        |> HttpBuilder.send (Delete_Secret_Response secretId)


postSecret : String -> String -> String -> Cmd Msg
postSecret token name value =
    HttpBuilder.post ("https://api.zeit.co/now/secrets/")
        |> withJsonBody
            (Encode.object
                [ ( "name", Encode.string name ), ( "value", Encode.string value ) ]
            )
        |> withHeader "Accept" "application/json"
        |> withHeader "Authorization" ("Bearer " ++ token)
        |> withExpect (Http.expectJson uuidDecoder)
        |> HttpBuilder.send (Post_Secret_Response name)



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


uuidDecoder : Decode.Decoder String
uuidDecoder =
    Decode.field "uid" Decode.string
