module Messages exposing (..)

import Deployments.Messages
import Aliases.Messages
import Secrets.Messages
import Login.Messages
import About.About exposing (AboutMsg)
import Routing


type Msg
    = DeploymentsMsg Deployments.Messages.Msg
    | AliasesMsg Aliases.Messages.Msg
    | SecretsMsg Secrets.Messages.Msg
    | AboutMsg AboutMsg
    | LoginMsg Login.Messages.Msg
    | LogoutMsg
    | GoTo (Maybe Routing.Route)
    | Start_Load_Token
    | Load_Token String
