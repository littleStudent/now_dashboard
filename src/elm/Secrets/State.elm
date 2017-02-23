module Secrets.State exposing (..)

import Secrets.Messages exposing (..)
import Secrets.Types exposing (Model, SecretRequest)
import Secrets.Rest exposing (..)
import Dict
import List


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Fetch_Secrets_Request ->
            ( { model | requests = (Dict.fromList (List.map (updateInProgress model.requests) (List.map .uid model.secrets))) }
            , fetchSecrets model.token
            )

        Fetch_Secrets_Response (Ok secrets) ->
            ( { model
                | secrets =
                    List.sortBy .name secrets
                , requests = (Dict.fromList (List.map (decreaseInProgress model.requests) (List.map .uid secrets)))
              }
            , Cmd.none
            )

        Fetch_Secrets_Response (Err _) ->
            ( model, Cmd.none )

        Delete_Secret_Request secretId ->
            ( { model
                | requests =
                    Dict.insert secretId
                        { inProgressCount = incrementProgressCount secretId model.requests
                        }
                        model.requests
              }
            , deleteSecret model.token secretId
            )

        Delete_Secret_Response _ (Ok secretId) ->
            ( { model
                | secrets = List.filter (\secret -> secret.uid /= secretId) model.secrets
                , requests =
                    Dict.insert secretId
                        { inProgressCount = decrementProgressCount secretId model.requests
                        }
                        model.requests
              }
            , Cmd.none
            )

        Delete_Secret_Response secretId _ ->
            ( { model
                | requests =
                    Dict.insert secretId
                        { inProgressCount = decrementProgressCount secretId model.requests
                        }
                        model.requests
              }
            , Cmd.none
            )

        Post_Secret_Request name value ->
            ( model
            , postSecret model.token name value
            )

        Post_Secret_Response name (Ok secretId) ->
            let
                requests =
                    Dict.insert secretId { inProgressCount = 0 } model.requests
            in
                ( { model
                    | secrets =
                        { uid = secretId, name = name, created = "2021-01-21T13:09:33.000Z" } :: model.secrets
                    , requests = (Dict.fromList (List.map (updateInProgress requests) (List.map .uid model.secrets)))
                  }
                , fetchSecrets model.token
                )

        Post_Secret_Response name _ ->
            ( model
            , Cmd.none
            )

        Input_Secret_Name name ->
            ( { model | newSecretName = name }
            , Cmd.none
            )

        Input_Secret_Value value ->
            ( { model | newSecretValue = value }
            , Cmd.none
            )


updateInProgress : Dict.Dict String SecretRequest -> String -> ( String, SecretRequest )
updateInProgress requests deploymentId =
    ( deploymentId, { inProgressCount = incrementProgressCount deploymentId requests } )


decreaseInProgress : Dict.Dict String SecretRequest -> String -> ( String, SecretRequest )
decreaseInProgress requests deploymentId =
    ( deploymentId, { inProgressCount = decrementProgressCount deploymentId requests } )


incrementProgressCount : String -> Dict.Dict String SecretRequest -> Int
incrementProgressCount secretId requests =
    (getProgressCount secretId requests) + 1


decrementProgressCount : String -> Dict.Dict String SecretRequest -> Int
decrementProgressCount secretId requests =
    (getProgressCount secretId requests) - 1


getProgressCount : String -> Dict.Dict String SecretRequest -> Int
getProgressCount secretId requests =
    let
        request =
            Dict.get secretId requests
    in
        case request of
            Nothing ->
                0

            Just val ->
                val.inProgressCount
