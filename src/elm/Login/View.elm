module Login.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import String
import HttpBuilder exposing (..)
import Navigation
import Login.Rest exposing (authenticate)
import Login.Types exposing (..)
import Login.Messages exposing (..)
import Ports exposing (..)


-- login component


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Set_Token newToken ->
            ( { model | token = newToken, errorMessage = "" }
            , Cmd.none
            )

        Login_Request ->
            ( { model | inProgress = True }
            , authenticate model.token
            )

        Login_Response newToken (Ok _) ->
            ( { model
                | isLoggedIn = True
                , token = newToken
                , inProgress = False
              }
            , Cmd.batch [ Navigation.newUrl "/deployments", setToken newToken ]
            )

        Login_Response newToken (Err err) ->
            let
                _ =
                    Debug.log "error" err
            in
                ( { model
                    | errorMessage = "provided token is not authorized"
                    , inProgress = False
                  }
                , Cmd.none
                )


view : Model -> Html Msg
view model =
    div [ class "container content-container", id "login-container" ]
        [ input [ class "", type_ "password", placeholder "Enter your now token", onInput Set_Token ] []
        , div [] [ text "get your token ", a [ href "https://zeit.co/account#api-tokens", target "_blank" ] [ text "here" ] ]
        , loginButton (String.isEmpty model.token)
        , spinner model.inProgress
        , errorMessage model.errorMessage
        , div [ id "faq-container" ]
            [ p [ style [ ( "font-weight", "bold" ) ] ] [ text "## Description" ]
            , ul [ style [ ( "list-style-type", "circle" ) ] ]
                [ li [] [ text "this is a dashboard in which you get a good overview of your deployments" ]
                , li []
                    [ text "source code is available on github"
                    , a [ href "https://github.com/littleStudent/now_dashboard" ] [ text " frontend" ]
                    ]
                , li [] [ text "your zeit API token is never stored" ]
                ]
            , p [ style [ ( "font-weight", "bold" ) ] ] [ text "## Features" ]
            , ul [ style [ ( "list-style-type", "circle" ) ] ]
                [ li [] [ text "list deployments" ]
                , li [] [ text "delete deployments" ]
                , li [] [ text "ping deployments to wake them up" ]
                , li [] [ text "show the aliases for the deployments" ]
                , li [] [ text "set new aliases with autocompletion" ]
                , li [] [ text "list aliases" ]
                , li [] [ text "list secrets" ]
                ]
            ]
        ]


loginButton : Bool -> Html Msg
loginButton isHidden =
    if isHidden then
        text ""
    else
        button [ class "", onClick Login_Request ] [ text "Login" ]


errorMessage : String -> Html Msg
errorMessage errorMessage =
    if String.isEmpty errorMessage then
        text ""
    else
        div [ class "error-text" ] [ text errorMessage ]


spinner : Bool -> Html Msg
spinner isShown =
    if isShown then
        div [ class "sk-wave" ]
            [ div [ class "sk-rect sk-rect1" ] []
            , div [ class "sk-rect sk-rect2" ] []
            , div [ class "sk-rect sk-rect3" ] []
            , div [ class "sk-rect sk-rect4" ] []
            , div [ class "sk-rect sk-rect5" ] []
            ]
    else
        text ""
