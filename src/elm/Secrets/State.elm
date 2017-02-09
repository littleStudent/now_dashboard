module Secrets.State exposing (..)

import Secrets.Messages exposing (..)
import Secrets.Types exposing (Model)
import Secrets.Rest exposing (..)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Fetch_Secrets_Response (Ok secrets) ->
            ( { model | secrets = List.sortBy .name secrets }
            , Cmd.none
            )

        Fetch_Secrets_Response (Err _) ->
            ( model, Cmd.none )

        Delete_Secret_Response (Ok _) ->
            ( model
            , Cmd.none
            )

        Delete_Secret_Response (Err _) ->
            ( model, Cmd.none )

        Delete_Secret_Request secretId ->
            ( model, Cmd.none )
