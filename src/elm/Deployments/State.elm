module Deployments.State exposing (..)

import Aliases.Types exposing (Alias)
import Array
import Deployments.Autocomplete
import Deployments.Messages exposing (..)
import Deployments.Rest exposing (deleteDeployment, fetchDeployment, fetchDeployments, pingDeployments, setAliasForDeployment)
import Deployments.Types exposing (Deployment, DeploymentRequest, DeploymentState, Model, SetAliasResponse)
import Dict
import List
import Navigation


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Fetch_Deployments_Request ->
            ( model, fetchDeployments model.token )

        Fetch_Deployments_Response (Ok receiveDeployments) ->
            ( { model
                | deployments = receiveDeployments
                , requests = Dict.fromList (List.map (updateInProgress model.requests) (List.map .uid (List.filter (\deployment -> deployment.name == model.selectedAliasName) receiveDeployments)))
              }
            , Cmd.batch (List.map (fetchDeployment model.token) (List.filter (\deployment -> deployment.name == model.selectedAliasName) receiveDeployments))
            )

        Fetch_Deployments_Response (Err _) ->
            ( { model | deployments = model.deployments }, Cmd.none )

        Fetch_Deployment_Response dep (Ok deployment) ->
            ( { model
                | deployments = List.map (setDeploymentAtUID deployment) model.deployments
                , requests =
                    Dict.insert deployment.uid
                        { inProgressCount = decrementProgressCount deployment.uid model.requests
                        }
                        model.requests
              }
            , Cmd.none
            )

        Fetch_Deployment_Response deployment (Err _) ->
            ( { model
                | deployments = model.deployments
                , requests =
                    Dict.insert deployment.uid
                        { inProgressCount = decrementProgressCount deployment.uid model.requests
                        }
                        model.requests
              }
            , Cmd.none
            )

        Delete_Deployment_Request deploymentId ->
            ( { model
                | deployments = model.deployments
                , requests =
                    Dict.insert deploymentId
                        { inProgressCount = incrementProgressCount deploymentId model.requests
                        }
                        model.requests
              }
            , deleteDeployment model.token deploymentId
            )

        Delete_Deployment_Response deploymentId (Ok deploymentState) ->
            let
                index =
                    indicesOf deploymentState model.deployments

                deploymentArray =
                    Array.fromList model.deployments
            in
            case index of
                Nothing ->
                    ( { model | deployments = model.deployments }, Cmd.none )

                Just val ->
                    ( { model
                        | deployments = removeFromList val model.deployments
                        , requests =
                            Dict.insert deploymentId
                                { inProgressCount = decrementProgressCount deploymentId model.requests
                                }
                                model.requests
                      }
                    , Cmd.none
                    )

        Delete_Deployment_Response deploymentId _ ->
            ( { model
                | deployments = model.deployments
                , requests =
                    Dict.insert deploymentId
                        { inProgressCount = decrementProgressCount deploymentId model.requests
                        }
                        model.requests
              }
            , Cmd.none
            )

        Set_Alias_Request deploymentId ->
            let
                foundAutcompleteMode =
                    Dict.get deploymentId model.autocompleteMode
            in
            case foundAutcompleteMode of
                Nothing ->
                    ( model, Cmd.none )

                Just val ->
                    case val.selectedAliasName of
                        Nothing ->
                            ( model, Cmd.none )

                        Just val2 ->
                            ( { model
                                | requests =
                                    Dict.insert deploymentId
                                        { inProgressCount = incrementProgressCount deploymentId model.requests
                                        }
                                        model.requests
                              }
                            , setAliasForDeployment model.token val2 deploymentId
                            )

        Set_Alias_Response deploymentId (Ok setAliasResponse) ->
            ( { model
                | aliases = List.map (updateAlias setAliasResponse deploymentId) model.aliases
                , editMode = Dict.remove deploymentId model.editMode
                , requests =
                    Dict.insert deploymentId
                        { inProgressCount = decrementProgressCount deploymentId model.requests
                        }
                        model.requests
              }
            , Cmd.none
            )

        Set_Alias_Response deploymentId _ ->
            ( { model
                | deployments = model.deployments
                , requests =
                    Dict.insert deploymentId
                        { inProgressCount = decrementProgressCount deploymentId model.requests
                        }
                        model.requests
              }
            , Cmd.none
            )

        Start_Editing_Deployment deploymentId ->
            let
                editMode =
                    Dict.get deploymentId model.editMode
            in
            case editMode of
                Nothing ->
                    ( { model
                        | editMode = Dict.insert deploymentId { aliasName = "", errorMessage = "", successMessage = "" } model.editMode
                        , autocompleteMode = Dict.insert deploymentId Deployments.Autocomplete.initialModel model.autocompleteMode
                      }
                    , Cmd.none
                    )

                Just val ->
                    ( { model | editMode = Dict.insert deploymentId { val | aliasName = "" } model.editMode }, Cmd.none )

        End_Editing_Deployment deploymentId ->
            ( { model | editMode = Dict.remove deploymentId model.editMode }, Cmd.none )

        Input_New_Alias_Name deploymentId aliasName ->
            let
                editMode =
                    Dict.get deploymentId model.editMode
            in
            case editMode of
                Nothing ->
                    ( model, Cmd.none )

                Just val ->
                    ( { model | editMode = Dict.insert deploymentId { val | aliasName = aliasName } model.editMode }, Cmd.none )

        Select_Alias aliasName ->
            ( { model | selectedAliasName = aliasName }
            , Navigation.newUrl ("/deployments/" ++ aliasName)
            )

        Ping_Deployment_Response deployment (Ok _) ->
            ( { model
                | requests =
                    Dict.insert deployment.uid
                        { inProgressCount = decrementProgressCount deployment.uid model.requests
                        }
                        model.requests
              }
            , fetchDeployment model.token deployment
            )

        Ping_Deployment_Response deployment (Err _) ->
            ( { model
                | requests =
                    Dict.insert deployment.uid
                        { inProgressCount = decrementProgressCount deployment.uid model.requests
                        }
                        model.requests
              }
            , fetchDeployment model.token deployment
            )

        Ping_Deployment_Request deployment ->
            ( { model
                | requests =
                    Dict.insert deployment.uid
                        { inProgressCount = incrementProgressCount deployment.uid model.requests
                        }
                        model.requests
              }
            , pingDeployments deployment
            )

        AutocompleteMsg autocompleteMode deployment subMsg ->
            let
                ( updatedAutocomplete, cmd ) =
                    Deployments.Autocomplete.update subMsg
                        { autocompleteMode | aliases = model.aliases }

                newAutocompletes =
                    Dict.insert deployment.uid updatedAutocomplete model.autocompleteMode
            in
            ( { model
                | autocompleteMode = newAutocompletes
              }
            , Cmd.map (AutocompleteMsg updatedAutocomplete deployment) cmd
            )


incrementProgressCount : String -> Dict.Dict String DeploymentRequest -> Int
incrementProgressCount deploymentId requests =
    getProgressCount deploymentId requests + 1


decrementProgressCount : String -> Dict.Dict String DeploymentRequest -> Int
decrementProgressCount deploymentId requests =
    getProgressCount deploymentId requests - 1


getProgressCount : String -> Dict.Dict String DeploymentRequest -> Int
getProgressCount deploymentId requests =
    let
        request =
            Dict.get deploymentId requests
    in
    case request of
        Nothing ->
            0

        Just val ->
            val.inProgressCount


updateDeployment : List Deployment -> Deployment -> List Deployment
updateDeployment list deployment =
    let
        updateFn depl =
            if deployment.uid == depl.uid then
                deployment
            else
                depl
    in
    List.map updateFn list


updateInProgress : Dict.Dict String DeploymentRequest -> String -> ( String, DeploymentRequest )
updateInProgress requests deploymentId =
    ( deploymentId, { inProgressCount = incrementProgressCount deploymentId requests } )


updateAlias : SetAliasResponse -> String -> Alias -> Alias
updateAlias setAliasResponse deploymentId aliasToUpdate =
    if setAliasResponse.oldId == aliasToUpdate.deploymentId then
        { aliasToUpdate | deploymentId = deploymentId }
    else
        aliasToUpdate


setDeploymentAtUID : DeploymentState -> Deployment -> Deployment
setDeploymentAtUID newDeployment oldDeployment =
    if oldDeployment.uid == newDeployment.uid then
        { oldDeployment | state = Just newDeployment.state }
    else
        oldDeployment


removeFromList : Int -> List Deployment -> List Deployment
removeFromList i xs =
    List.take i xs ++ List.drop (i + 1) xs


indicesOf : DeploymentState -> List Deployment -> Maybe Int
indicesOf thing things =
    things
        |> List.indexedMap (,)
        |> List.filter (\( idx, item ) -> item.uid == thing.uid)
        |> List.map Tuple.first
        |> List.head
