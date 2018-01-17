module Login.View exposing (..)

import Delay exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Login.Messages exposing (..)
import Login.Rest exposing (registration, verify)
import Login.Types exposing (..)
import Navigation
import Ports exposing (..)
import String
import Time


-- login component


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Set_Email newToken ->
            ( { model | email = newToken, errorMessage = "" }
            , Cmd.none
            )

        Registration_Request ->
            ( { model | inProgress = True }
            , registration model.email
            )

        Registration_Response (Ok result) ->
            ( { model
                | registrationToken = result.token
                , securityCode = result.securityCode
              }
            , verify model.email result.token
            )

        Registration_Response (Err err) ->
            ( { model
                | errorMessage = "Invalid email"
                , inProgress = False
              }
            , Cmd.none
            )

        Verification_Request ->
            ( model
            , verify model.email model.registrationToken
            )

        Verification_Response (Ok token) ->
            ( { model
                | token = token
                , isLoggedIn = True
                , inProgress = False
              }
            , Cmd.batch [ Navigation.newUrl "/deployments", setToken token ]
            )

        Verification_Response (Err err) ->
            ( model
            , after 2000 Time.millisecond Verification_Request
            )


view : Model -> Html Msg
view model =
    div [ class "container content-container", id "login-container" ]
        [ input [ class "", placeholder "Enter your email", onInput Set_Email ] []
        , spinner model.inProgress
        , if model.securityCode /= "" then
            span []
                [ text "Check your email / Verification Code: "
                , span [] [ text model.securityCode ]
                ]
          else if not model.inProgress then
            loginButton (String.isEmpty model.email)
          else
            text ""
        , errorMessage model.errorMessage
        ]


loginButton : Bool -> Html Msg
loginButton isHidden =
    if isHidden then
        text ""
    else
        button [ class "", onClick Registration_Request ] [ text "Login" ]


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
