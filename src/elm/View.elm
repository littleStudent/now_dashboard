module View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Messages exposing (Msg(..))
import Types exposing (Model)
import Deployments.List
import Deployments.Types exposing (Deployment)
import Aliases.List
import Secrets.List
import About.About
import Login.View
import Routing exposing (Route(..))


view : Model -> Html Msg
view model =
    div []
        [ nav model.route model.login.isLoggedIn
        , div [ class "" ] [ page model ]
        ]


nav : Routing.Route -> Bool -> Html Msg
nav route isLoggedIn =
    div [ class "navigation-bar" ]
        [ div [ class "container" ]
            [ a [ class "navigation-header", href "/" ]
                [ h5 [ class "navigation-title" ]
                    [ span []
                        [ img [ src "" ] []
                        ]
                    , text ("Nash")
                    ]
                ]
            , if isLoggedIn then
                a [ onClick ShowDeployments ]
                    [ p
                        [ class
                            (case route of
                                DeploymentsRoute aliasName ->
                                    "selected-item navigation-item"

                                _ ->
                                    "navigation-item"
                            )
                        ]
                        [ text "Deployments" ]
                    ]
              else
                text ""
            , if isLoggedIn then
                a [ onClick ShowAliases ]
                    [ p
                        [ class
                            (if route == AliasesRoute then
                                "selected-item navigation-item"
                             else
                                "navigation-item"
                            )
                        ]
                        [ text "Aliases" ]
                    ]
              else
                text ""
            , if isLoggedIn then
                a [ onClick ShowSecrets ]
                    [ p
                        [ class
                            (if route == SecretsRoute then
                                "selected-item navigation-item"
                             else
                                "navigation-item"
                            )
                        ]
                        [ text "Secrets" ]
                    ]
              else
                text ""
            , if isLoggedIn then
                a [ onClick LogoutMsg ]
                    [ p
                        [ class "navigation-item" ]
                        [ text "Logout" ]
                    ]
              else
                text ""
            ]
        ]


page : Model -> Html Msg
page model =
    case model.route of
        DeploymentsRoute aliasName ->
            let
                deployments =
                    model.deployments
            in
                Html.map DeploymentsMsg
                    (Deployments.List.view
                        { deployments
                            | deployments = (List.sortWith deploymentCompare model.deployments.deployments)
                            , aliases = model.aliases.aliases
                            , token = model.login.token
                        }
                    )

        AliasesRoute ->
            Html.map AliasesMsg (Aliases.List.view model.aliases)

        SecretsRoute ->
            Html.map SecretsMsg (Secrets.List.view model.secrets)

        AboutRoute ->
            Html.map AboutMsg About.About.view

        LoginRoute ->
            Html.map LoginMsg (Login.View.view model.login)

        _ ->
            notFoundView


notFoundView : Html msg
notFoundView =
    div []
        [ text "Not found"
        ]


deploymentCompare : Deployment -> Deployment -> Basics.Order
deploymentCompare a b =
    case compare a.name b.name of
        EQ ->
            compare b.created a.created

        order ->
            order
