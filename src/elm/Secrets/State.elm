module Secrets.State exposing (..)

import Secrets.Messages exposing (..)
import Secrets.Types exposing (Secret)


update : Msg -> List Secret -> ( List Secret, Cmd Msg )
update msg secrets =
    case msg of
        Fetch_Secrets_Response (Ok secrets) ->
            ( List.sortBy .name secrets
            , Cmd.none
            )

        Fetch_Secrets_Response (Err _) ->
            ( secrets, Cmd.none )
