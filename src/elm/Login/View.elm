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
            ( model
            , authenticate model.token
            )

        Login_Response (Ok newToken) ->
            ( { model | isLoggedIn = True, token = newToken }
            , Cmd.batch [ Navigation.newUrl "/#/deployments", setToken newToken ]
            )

        Login_Response (Err _) ->
            ( { model | errorMessage = "provided token is not authorized" }, Cmd.none )


view : Model -> Html Msg
view model =
    div [ class "container content-container", id "login-container" ]
        [ input [ class "", type_ "password", placeholder "Enter your now token", onInput Set_Token ] []
        , div [] [ text "get your token ", a [ href "https://zeit.co/account#api-tokens" ] [ text "here" ] ]
        , loginButton (String.isEmpty model.token)
        , errorMessage model.errorMessage
        , div [ id "faq-container" ]
            [ p [ style [ ( "font-weight", "bold" ) ] ] [ text "## Description" ]
            , ul [ style [ ( "list-style-type", "circle" ) ] ]
                [ li [] [ text "this is a dashboard in which you get a good overview of your deployments" ]
                , li []
                    [ text "source code is available on github"
                    , a [ href "https://github.com/littleStudent/now_dashbaord" ] [ text " frontend" ]
                    , a [ href "https://github.com/littleStudent/now_dashboard_backend" ] [ text " backend" ]
                    ]
                , li [] [ text "your zeit API token is nerver stored" ]
                , li [] [ text "since the zeit API does not support CORS at the moment, all traffic is running through microservices deployed to now" ]
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
