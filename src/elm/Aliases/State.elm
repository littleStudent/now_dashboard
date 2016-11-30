module Aliases.State exposing (..)

import Aliases.Messages exposing (..)
import Aliases.Types exposing (Alias)


update : Msg -> List Alias -> ( List Alias, Cmd Msg )
update msg aliases =
    case msg of
        Fetch_Aliases_Response (Ok aliases) ->
            ( List.sortBy .aliasName aliases
            , Cmd.none
            )

        Fetch_Aliases_Response (Err _) ->
            ( aliases, Cmd.none )
