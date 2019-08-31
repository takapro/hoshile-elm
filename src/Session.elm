module Session exposing (Model, Msg(..), init, update)

import Browser.Navigation as Nav
import Entity.CartEntry as CartEntry exposing (CartEntry)
import Entity.User exposing (User)


type alias Model =
    { user : Maybe User
    , shoppingCart : List CartEntry
    }


type Msg
    = Login User String
    | Logout String
    | Update User
    | MergeCart (List CartEntry) (Maybe String)
    | ClearCart


init : Model
init =
    Model Nothing []


update : Msg -> Nav.Key -> Model -> ( Model, Cmd msg )
update msg key model =
    case msg of
        Login user path ->
            ( { model | user = Just user }, Nav.pushUrl key path )

        Logout path ->
            ( { model | user = Nothing }, Nav.replaceUrl key path )

        Update user ->
            ( { model | user = Just user }, Cmd.none )

        MergeCart cart maybePath ->
            ( { model | shoppingCart = CartEntry.mergeCart model.shoppingCart cart }
            , pushCmd key maybePath
            )

        ClearCart ->
            ( { model | shoppingCart = [] }, Cmd.none )


pushCmd : Nav.Key -> Maybe String -> Cmd msg
pushCmd key maybePath =
    case maybePath of
        Just path ->
            Nav.pushUrl key path

        _ ->
            Cmd.none
