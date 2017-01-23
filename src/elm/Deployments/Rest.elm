module Deployments.Rest exposing (..)

import HttpBuilder exposing (..)
import Http exposing (..)
import Json.Decode as Decode exposing (Decoder, list, string, field, decodeString, at)
import Json.Encode as Encode exposing (..)
import Deployments.Messages exposing (..)
import Deployments.Types exposing (Deployment, DeploymentState, SetAliasResponse)


-- HTTP


pingDeployments : Deployment -> Cmd Msg
pingDeployments deployment =
    HttpBuilder.get ("https://" ++ deployment.url)
        |> HttpBuilder.send (Ping_Deployment_Response deployment)


fetchDeployments : String -> Cmd Msg
fetchDeployments token =
    HttpBuilder.get "https://api.zeit.co/now/deployments"
        |> withHeader "Accept" "application/json"
        |> withHeader "Authorization" ("Bearer " ++ token)
        |> withExpect (Http.expectJson deploymentsDecoder)
        |> HttpBuilder.send Fetch_Deployments_Response


fetchDeployment : String -> Deployment -> Cmd Msg
fetchDeployment token deployment =
    HttpBuilder.get ("https://api.zeit.co/now/deployments/" ++ deployment.uid)
        |> withHeader "Accept" "application/json"
        |> withHeader "Authorization" ("Bearer " ++ token)
        |> withExpect (Http.expectJson memberDecoder2)
        |> HttpBuilder.send (Fetch_Deployment_Response deployment)


setAliasForDeployment : String -> String -> String -> Cmd Msg
setAliasForDeployment token aliasName deploymentId =
    HttpBuilder.post ("https://now.deployments.aliases.autcoding.com/" ++ deploymentId)
        |> withJsonBody (Encode.object [ ( "alias", Encode.string aliasName ) ])
        |> withHeader "Accept" "application/json"
        |> withHeader "Authorization" token
        |> withExpect (Http.expectJson setAliasResponseDecoder)
        |> HttpBuilder.send (Set_Alias_Response deploymentId)


deleteDeployment : String -> String -> Cmd Msg
deleteDeployment token deploymentId =
    HttpBuilder.delete ("https://api.zeit.co/now/deployments/" ++ deploymentId)
        |> withHeader "Accept" "application/json"
        |> withHeader "Authorization" ("Bearer " ++ token)
        |> withHeader "Access-Control-Allow-Headers" "Access-Control-Allow-Methods"
        |> withHeader "Access-Control-Allow-Methods" "DELETE"
        |> withExpect (Http.expectJson memberDecoder2)
        |> HttpBuilder.send (Delete_Deployment_Response deploymentId)



-- DECODERS


deploymentsDecoder : Decode.Decoder (List Deployment)
deploymentsDecoder =
    Decode.field "deployments" deploymentDecoder


deploymentDecoder : Decode.Decoder (List Deployment)
deploymentDecoder =
    Decode.list memberDecoder


memberDecoder : Decode.Decoder Deployment
memberDecoder =
    Decode.map5 Deployment
        (Decode.field "uid" Decode.string)
        (Decode.field "name" Decode.string)
        (Decode.field "url" Decode.string)
        (Decode.field "created" Decode.string)
        (Decode.maybe (Decode.field "state" Decode.string))


memberDecoder2 : Decode.Decoder DeploymentState
memberDecoder2 =
    Decode.map3 DeploymentState
        (Decode.field "uid" Decode.string)
        (Decode.maybe (Decode.field "host" Decode.string))
        (Decode.field "state" Decode.string)


setAliasResponseDecoder : Decode.Decoder SetAliasResponse
setAliasResponseDecoder =
    Decode.map3 SetAliasResponse
        (Decode.field "oldId" Decode.string)
        (Decode.field "uid" Decode.string)
        (Decode.field "created" Decode.string)
