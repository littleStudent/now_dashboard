module Deployments.List exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Deployments.Messages exposing (Msg(..))
import Deployments.Types exposing (Deployment, Model, EditMode, DeploymentRequest)
import Deployments.Autocomplete
import Aliases.Types exposing (Alias)
import Date exposing (fromTime)
import Date.Format
import List.Extra
import String
import Dict
import FontAwesome
import Color


-- hello component


view : Model -> Html Msg
view model =
    div [ class "content-container row " ]
        [ quickjumpNavigation model
        , deploymentSection model
        ]


quickjumpNavigation : Model -> Html Msg
quickjumpNavigation model =
    div [ class "hidden-md-down col-lg-3", id "quickjump" ]
        [ button [ style [ ( "font-weight", "bold" ) ], onClick Fetch_Deployments_Request ] [ text "## refresh" ]
        , ul [ class "" ]
            (List.map
                (\deployments ->
                    let
                        deployment =
                            List.head deployments
                    in
                        case deployment of
                            Nothing ->
                                text "nothing"

                            Just val ->
                                li [ onClick (Select_Alias val.name) ]
                                    [ span
                                        [ (if val.name == model.selectedAliasName then
                                            class "selected-item"
                                           else
                                            class ""
                                          )
                                        ]
                                        [ text ("# " ++ val.name) ]
                                    ]
                )
                (groupDeploymentList model.deployments)
            )
        ]


deploymentSection : Model -> Html Msg
deploymentSection model =
    div [ class "deployment-content offset-lg-3 offset-md-0 col-lg-8 col-md-12" ]
        (List.map (deploymentTable model) (filterDeploymentList model.selectedAliasName model.deployments))


deploymentTable : Model -> List Deployment -> Html Msg
deploymentTable model deployments =
    let
        deployment =
            List.head deployments
    in
        case deployment of
            Nothing ->
                text "nothing"

            Just val ->
                div [ class "deployments-section" ]
                    [ p [ class "deployments-section-title bold-text", id val.name ] [ text ("## " ++ val.name) ]
                    , table [ class "table", style [ ( "table-layout", "fixed" ) ] ]
                        [ thead []
                            [ tr []
                                [ th [] [ text "name" ]
                                , th [] [ text "state" ]
                                , th [ class "" ] [ text "alias" ]
                                , th [] [ text "actions" ]
                                , th [ class "hidden-md-down" ] [ text "" ]
                                ]
                            ]
                        , tbody [] (List.map (deploymentRow model.aliases model.editMode model.autocompleteMode model.requests) deployments)
                        ]
                    ]


deploymentRow : List Alias -> Dict.Dict String EditMode -> Dict.Dict String Deployments.Autocomplete.Model -> Dict.Dict String DeploymentRequest -> Deployment -> Html Msg
deploymentRow aliases editMode autocompleteMode requests deployment =
    let
        created =
            fromTime (Result.withDefault 0 (String.toFloat deployment.created))
    in
        tr []
            [ td []
                [ p [ class "deployment-name" ]
                    [ a [ href ("https://" ++ deployment.url), target "_blank" ]
                        [ text (deployment.name ++ "  "), FontAwesome.external_link_square Color.darkGray 12 ]
                    ]
                , p [ class "deployment-uid" ] [ text (deployment.uid) ]
                ]
            , td []
                [ p [ class "margin-bottom-0", deploymentState (Maybe.withDefault "not loaded" deployment.state) ] [ text (Maybe.withDefault "not loaded" deployment.state) ]
                , p [ class "" ] [ text (Date.Format.format "%a, %b %d %I:%M %p" created) ]
                ]
            , td [ class "bold-text" ]
                [ div [ class "flex-single-column" ] (List.map (aliasView deployment) (List.filter (\alias -> alias.deploymentId == deployment.uid) aliases)) ]
            , actions aliases deployment editMode autocompleteMode requests
            , td [ class "hidden-md-down", style [ ( "height", "70px" ) ] ] [ loadingSpinner deployment requests ]
            ]


loadingSpinner : Deployment -> Dict.Dict String DeploymentRequest -> Html Msg
loadingSpinner deployment requests =
    let
        request =
            Dict.get deployment.uid requests
    in
        case request of
            Nothing ->
                text ""

            Just val ->
                if val.inProgressCount > 0 then
                    spinner
                else
                    text ""


spinner : Html Msg
spinner =
    div [ class "sk-wave" ]
        [ div [ class "sk-rect sk-rect1" ] []
        , div [ class "sk-rect sk-rect2" ] []
        , div [ class "sk-rect sk-rect3" ] []
        , div [ class "sk-rect sk-rect4" ] []
        , div [ class "sk-rect sk-rect5" ] []
        ]


actions : List Alias -> Deployment -> Dict.Dict String EditMode -> Dict.Dict String Deployments.Autocomplete.Model -> Dict.Dict String DeploymentRequest -> Html Msg
actions aliases deployment editMode autocompleteMode requests =
    td [ class "flex-single-column" ]
        [ deleteBtn deployment aliases
        , if (Maybe.withDefault "not loaded" deployment.state) == "FROZEN" then
            pingBtn deployment
          else
            text ""
        , if Dict.member deployment.uid editMode then
            setAliasBtn deployment autocompleteMode
          else
            button [ class "alias-button primary-color", onClick (Start_Editing_Deployment deployment.uid) ] [ text "set alias" ]
        ]


setAliasBtn : Deployment -> Dict.Dict String Deployments.Autocomplete.Model -> Html Msg
setAliasBtn deployment autocompleteMode =
    let
        mode =
            (Dict.get deployment.uid autocompleteMode)
    in
        case mode of
            Nothing ->
                text ""

            Just val ->
                span [ class "flex-single-column" ]
                    [ Html.map (AutocompleteMsg val deployment)
                        (Deployments.Autocomplete.view
                            (Dict.get deployment.uid autocompleteMode)
                        )
                    , span [ class "flex-single-row" ]
                        [ button [ class "alias-btn", onClick (End_Editing_Deployment deployment.uid) ] [ text "cancel" ]
                        , button [ class "alias-btn", onClick (Set_Alias_Request deployment.uid) ] [ text "add" ]
                        ]
                    ]


pingBtn : Deployment -> Html Msg
pingBtn deployment =
    button
        [ class "regular ping-button blue"
        , onClick (Ping_Deployment_Request deployment)
        ]
        [ i [ class "" ] [], text "ping" ]


deleteBtn : Deployment -> List Alias -> Html.Html Msg
deleteBtn deployment aliases =
    case deployment.state of
        Nothing ->
            span [ class "info-text" ] [ text "" ]

        Just state ->
            if hasAlias deployment aliases then
                span [ class "info-text" ] [ text "" ]
            else
                button
                    [ class "regular delete-button red"
                    , onClick (Delete_Deployment_Request deployment.uid)
                    ]
                    [ i [ class "fa fa-pencil mr1" ] [], text "delete" ]


deploymentState : String -> Attribute a
deploymentState state =
    if state == "FROZEN" then
        style [ ( "color", "#006eff" ) ]
    else if state == "READY" then
        style [ ( "color", "green" ) ]
    else if state == "not loaded" then
        style [ ( "color", "darkgray" ) ]
    else
        style [ ( "color", "red" ) ]


hasAlias : Deployment -> List Alias -> Bool
hasAlias deployment aliases =
    List.member deployment.uid (List.map .deploymentId aliases)


aliasView : Deployment -> Alias -> Html Msg
aliasView deployment foundAlias =
    a
        [ href ("https://" ++ foundAlias.aliasName)
        , target "_blank"
        , class ""
        ]
        [ text foundAlias.aliasName
        ]


getAliasNameForDeployment : Deployment -> List Alias -> String
getAliasNameForDeployment deployment aliases =
    let
        foundAlias =
            List.Extra.find (\alias -> alias.deploymentId == deployment.uid) aliases
    in
        case foundAlias of
            Nothing ->
                ""

            Just val ->
                val.aliasName


groupDeploymentList : List Deployment -> List (List Deployment)
groupDeploymentList deployments =
    (List.Extra.groupWhile (\x y -> x.name == y.name) deployments)


filterDeploymentList : String -> List Deployment -> List (List Deployment)
filterDeploymentList selectedAlias groupedDeployments =
    List.filter
        (\deployments ->
            let
                deployment =
                    List.head deployments
            in
                case deployment of
                    Nothing ->
                        False

                    Just val ->
                        if val.name == selectedAlias then
                            True
                        else
                            False
        )
        (groupDeploymentList groupedDeployments)
