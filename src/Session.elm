module Session exposing (Model, Msg(..), init, update)

import Browser.Navigation as Nav
import Entity.User exposing (User)


type alias Model =
    { user : Maybe User
    , shoppingCart : List ()
    }


type Msg
    = Login User String
    | Logout String
    | Update User


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
