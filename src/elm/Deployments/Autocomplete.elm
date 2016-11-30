module Deployments.Autocomplete exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onBlur, onFocus)
import Autocomplete
import String
import Aliases.Types exposing (Alias)
import Dom
import Task


type alias Model =
    { autoState :
        Autocomplete.State
        -- Own the State of the menu in your model
    , query :
        String
        -- Perhaps you want to filter by a string?
    , aliases :
        List Alias
        -- The data you want to list and filter
    , howManyToShow : Int
    , selectedAliasName : Maybe String
    , showMenu : Bool
    , mouseOverDropdown : Bool
    }


initialModel : Model
initialModel =
    { aliases = []
    , autoState = Autocomplete.empty
    , howManyToShow = 10
    , query = ""
    , selectedAliasName = Nothing
    , showMenu = False
    , mouseOverDropdown = False
    }



-- Let's filter the data however we want


acceptablePeople : String -> List Alias -> List Alias
acceptablePeople query aliases =
    let
        lowerQuery =
            String.toLower query
    in
        List.filter (String.contains lowerQuery << String.toLower << .aliasName) aliases



-- Set up what will happen with your menu updates


updateConfig : Autocomplete.UpdateConfig Msg Alias
updateConfig =
    Autocomplete.updateConfig
        { toId = .aliasName
        , onKeyDown =
            \code maybeId ->
                if code == 13 then
                    Nothing
                else
                    Nothing
        , onTooLow = Nothing
        , onTooHigh = Nothing
        , onMouseEnter = \_ -> Just <| MouseEnterDropdown
        , onMouseLeave = \_ -> Just <| MouseLeaveDropdown
        , onMouseClick = \id -> Just <| SetAlias id
        , separateSelections = False
        }


type Msg
    = SetAutocompleteState Autocomplete.Msg
    | SetQuery String
    | SetAlias String
    | LooseFocus
    | SetFocus
    | MouseEnterDropdown
    | MouseLeaveDropdown
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetAutocompleteState autoMsg ->
            let
                ( newState, maybeMsg ) =
                    Autocomplete.update updateConfig autoMsg model.howManyToShow model.autoState (acceptablePeople model.query model.aliases)

                newModel =
                    { model | autoState = newState }
            in
                case maybeMsg of
                    Nothing ->
                        newModel ! []

                    Just updateMsg ->
                        update updateMsg newModel

        SetQuery newQuery ->
            let
                showMenu =
                    not << List.isEmpty <| (acceptablePeople newQuery model.aliases)
            in
                ( { model | query = newQuery, showMenu = showMenu, selectedAliasName = Just newQuery }, Cmd.none )

        SetAlias id ->
            let
                newModel =
                    setQuery model id
                        |> resetMenu
            in
                ( newModel, Task.attempt (\_ -> NoOp) (Dom.focus "president-input") )

        MouseEnterDropdown ->
            ( { model | mouseOverDropdown = True }, Cmd.none )

        MouseLeaveDropdown ->
            ( { model | mouseOverDropdown = False }, Cmd.none )

        LooseFocus ->
            if model.mouseOverDropdown then
                ( model, Cmd.none )
            else
                ( { model | showMenu = False }, Cmd.none )

        SetFocus ->
            ( { model | showMenu = True, mouseOverDropdown = False }, Cmd.none )

        NoOp ->
            model ! []



-- setup for your autocomplete view


viewConfig : Autocomplete.ViewConfig Alias
viewConfig =
    let
        customizedLi keySelected mouseSelected person =
            { attributes = [ classList [ ( "autocomplete-item", True ), ( "is-selected", keySelected || mouseSelected ) ] ]
            , children = [ Html.text person.aliasName ]
            }
    in
        Autocomplete.viewConfig
            { toId = .aliasName
            , ul =
                [ class "autocomplete-list" ]
                -- set classes for your list
            , li =
                customizedLi
                -- given selection states and a person, create some Html!
            }



-- and let's show it! (See an example for the full code snippet)
-- { autoState, query, aliases, showMenu }


view : Maybe Model -> Html Msg
view autocomplete =
    case autocomplete of
        Nothing ->
            text ""

        Just val ->
            div []
                [ input [ onInput SetQuery, value val.query, onBlur LooseFocus, onFocus SetFocus ] [ text val.query ]
                , if val.showMenu then
                    Html.map SetAutocompleteState (Autocomplete.view viewConfig val.howManyToShow val.autoState (acceptablePeople val.query val.aliases))
                  else
                    text ""
                ]


getAliasAtId people id =
    List.filter (\person -> person.aliasName == id) people
        |> List.head
        |> Maybe.withDefault (Alias "" "" "" "")


setQuery model id =
    { model
        | query = .aliasName <| getAliasAtId model.aliases id
        , selectedAliasName = Just <| .aliasName <| getAliasAtId model.aliases id
    }


resetMenu model =
    { model
        | autoState = Autocomplete.empty
        , showMenu = False
    }
