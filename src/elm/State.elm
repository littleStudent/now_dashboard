module State exposing (..)

import Messages exposing (Msg(..))
import Types exposing (Model)
import Deployments.State
import Aliases.Rest exposing (fetchAliases)
import Deployments.Rest exposing (fetchDeployments)
import Deployments.Messages
import Aliases.Messages
import Secrets.Rest exposing (fetchSecrets)
import Aliases.State
import Secrets.State exposing (update)
import Login.View
import Navigation
import Ports exposing (..)
import String
import Routing


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DeploymentsMsg subMsg ->
            let
                deployments =
                    model.deployments

                ( updatedDeployments, cmd ) =
                    Deployments.State.update subMsg
                        { deployments
                            | token = model.login.token
                            , aliases = model.aliases
                        }
            in
                if (subMsg == Deployments.Messages.Fetch_Deployments_Request) then
                    ( { model | deployments = updatedDeployments, aliases = updatedDeployments.aliases }
                    , Cmd.batch
                        [ Cmd.map DeploymentsMsg cmd
                        , Cmd.map AliasesMsg (fetchAliases model.login.token)
                        ]
                    )
                else
                    ( { model | deployments = updatedDeployments, aliases = updatedDeployments.aliases }, Cmd.map DeploymentsMsg cmd )

        AliasesMsg subMsg ->
            let
                ( updatedAliases, cmd ) =
                    Aliases.State.update subMsg model.aliases
            in
                ( { model | aliases = updatedAliases }, Cmd.map AliasesMsg cmd )

        SecretsMsg subMsg ->
            let
                secrets =
                    model.secrets

                ( updatedSecrets, cmd ) =
                    Secrets.State.update subMsg { secrets | token = model.login.token }
            in
                ( { model | secrets = updatedSecrets }, Cmd.map SecretsMsg cmd )

        AboutMsg subMsg ->
            ( model, Cmd.none )

        LoginMsg subMsg ->
            let
                ( updatedLogin, cmd ) =
                    Login.View.update subMsg model.login
            in
                ( { model | login = updatedLogin }, Cmd.map LoginMsg cmd )

        LogoutMsg ->
            let
                newLogin =
                    model.login
            in
                ( { model
                    | login =
                        { newLogin
                            | isLoggedIn = False
                            , token = ""
                            , errorMessage = ""
                        }
                  }
                , Cmd.batch
                    [ Navigation.newUrl "/login"
                    , setToken ""
                    ]
                )

        Start_Load_Token ->
            ( model, startLoadToken () )

        Load_Token token ->
            if String.isEmpty token then
                ( model, Navigation.newUrl "/login" )
            else
                let
                    newLogin =
                        model.login
                in
                    ( { model
                        | login =
                            { newLogin
                                | isLoggedIn = True
                                , token = token
                                , errorMessage = ""
                            }
                      }
                    , Cmd.batch
                        [ Cmd.map DeploymentsMsg (fetchDeployments token)
                        , Cmd.map AliasesMsg (fetchAliases token)
                        , Cmd.map SecretsMsg (fetchSecrets token)
                        ]
                    )

        ShowDeployments ->
            ( { model | route = Routing.DeploymentsRoute model.deployments.selectedAliasName }
            , Cmd.batch
                [ Navigation.newUrl ("/deployments/" ++ model.deployments.selectedAliasName)
                ]
            )

        ShowAliases ->
            ( { model | route = Routing.AliasesRoute }
            , Cmd.batch
                [ Navigation.newUrl "/aliases"
                , Cmd.map AliasesMsg (fetchAliases model.login.token)
                ]
            )

        ShowSecrets ->
            ( { model | route = Routing.SecretsRoute }
            , Cmd.batch
                [ Navigation.newUrl "/secrets"
                , Cmd.map SecretsMsg (fetchSecrets model.login.token)
                ]
            )

        GoTo route ->
            case route of
                Nothing ->
                    ( { model | route = Routing.DeploymentsRoute "" }
                    , Cmd.batch
                        [ Cmd.map DeploymentsMsg (fetchDeployments model.login.token)
                        , Cmd.map AliasesMsg (fetchAliases model.login.token)
                        ]
                    )

                Just route ->
                    case route of
                        Routing.DeploymentsRoute aliasName ->
                            ( { model | route = route }
                            , Cmd.map DeploymentsMsg (fetchDeployments model.login.token)
                            )

                        Routing.AliasesRoute ->
                            ( { model | route = route }, Cmd.none )

                        _ ->
                            ( { model | route = route }, Cmd.none )
