module Login.Rest exposing (..)

import Http exposing (..)
import HttpBuilder exposing (..)
import Json.Decode as Decode exposing (Decoder, at, decodeString, field, list, string)
import Json.Encode as Encode exposing (..)
import Login.Messages exposing (..)
import Login.Types exposing (RegistrationResponse)
import Secrets.Types exposing (Secret)


verify : String -> String -> Cmd Msg
verify email token =
    HttpBuilder.get ("https://api.zeit.co/now/registration/verify?email=" ++ email ++ "&token=" ++ token)
        |> withHeader "Accept" "application/json"
        |> withExpect (Http.expectJson (Decode.field "token" Decode.string))
        |> HttpBuilder.send Verification_Response


registration : String -> Cmd Msg
registration email =
    HttpBuilder.post "https://api.zeit.co/now/registration"
        |> withJsonBody
            (Encode.object
                [ ( "email", Encode.string email ), ( "tokenName", Encode.string "nash.now.sh" ) ]
            )
        |> withHeader "Accept" "application/json"
        |> withExpect (Http.expectJson registrationDecoder)
        |> HttpBuilder.send Registration_Response



-- DECODERS


registrationDecoder : Decode.Decoder RegistrationResponse
registrationDecoder =
    Decode.map2 RegistrationResponse
        (Decode.field "token" Decode.string)
        (Decode.field "securityCode" Decode.string)
