module Aliases.State exposing (..)

import Aliases.Messages exposing (..)
import Aliases.Types exposing (Model, AliasRequest, Alias)
import Aliases.Rest exposing (deleteAlias)
import Dict
import Array


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Fetch_Aliases_Response (Ok aliases) ->
            ( { model | aliases = List.sortBy .aliasName aliases }
            , Cmd.none
            )

        Fetch_Aliases_Response (Err _) ->
            ( model, Cmd.none )

        Delete_Alias_Request aliasId ->
            ( { model
                | requests =
                    Dict.insert aliasId
                        { inProgressCount = incrementProgressCount aliasId model.requests
                        }
                        model.requests
              }
            , deleteAlias model.token aliasId
            )

        Delete_Alias_Response aliasId (Ok _) ->
            let
                index =
                    indicesOf aliasId model.aliases
            in
                case index of
                    Nothing ->
                        ( model, Cmd.none )

                    Just val ->
                        ( { model
                            | aliases = (removeFromList val model.aliases)
                            , requests =
                                Dict.insert aliasId
                                    { inProgressCount = decrementProgressCount aliasId model.requests
                                    }
                                    model.requests
                          }
                        , Cmd.none
                        )

        Delete_Alias_Response aliasId (Err _) ->
            ( model, Cmd.none )


incrementProgressCount : String -> Dict.Dict String AliasRequest -> Int
incrementProgressCount aliasId requests =
    (getProgressCount aliasId requests) + 1


decrementProgressCount : String -> Dict.Dict String AliasRequest -> Int
decrementProgressCount aliasId requests =
    (getProgressCount aliasId requests) - 1


getProgressCount : String -> Dict.Dict String AliasRequest -> Int
getProgressCount aliasId requests =
    let
        request =
            Dict.get aliasId requests
    in
        case request of
            Nothing ->
                0

            Just val ->
                val.inProgressCount


indicesOf : String -> List Alias -> Maybe Int
indicesOf uid things =
    things
        |> List.indexedMap (,)
        |> List.filter (\( idx, item ) -> item.uid == uid)
        |> List.map Tuple.first
        |> List.head


removeFromList : Int -> List Alias -> List Alias
removeFromList i xs =
    (List.take i xs) ++ (List.drop (i + 1) xs)
