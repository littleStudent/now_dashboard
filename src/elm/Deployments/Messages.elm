module Deployments.Messages exposing (..)

import Http exposing (..)
import Deployments.Types exposing (Deployment, DeploymentState, SetAliasResponse, DeploymentId)
import Deployments.Autocomplete


type Msg
    = NoOp
    | Fetch_Deployments_Request
    | Fetch_Deployments_Response (Result Http.Error (List Deployment))
    | Fetch_Deployment_Response Deployment (Result Http.Error DeploymentState)
    | Delete_Deployment_Request String
    | Delete_Deployment_Response DeploymentId (Result Http.Error DeploymentState)
    | Set_Alias_Request String
    | Set_Alias_Response DeploymentId (Result Http.Error SetAliasResponse)
    | Ping_Deployment_Request Deployment
    | Ping_Deployment_Response Deployment (Result Http.Error ())
    | Start_Editing_Deployment DeploymentId
    | End_Editing_Deployment DeploymentId
    | Input_New_Alias_Name DeploymentId String
    | Navigate_To_Element String
    | AutocompleteMsg Deployments.Autocomplete.Model Deployment Deployments.Autocomplete.Msg
