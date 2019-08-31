module Session exposing (Model, Msg(..), init, update)

import Browser.Navigation as Nav
import Config
import Entity.CartEntry as CartEntry exposing (CartEntry)
import Entity.User exposing (User)
import Json.Decode as Decode
import Json.Encode as Encode
import Util.Fetch as Fetch exposing (FetchState(..))


type alias Model =
    { user : Maybe User
    , shoppingCart : List CartEntry
    }


type Msg
    = Login User String
    | Logout String
    | Update User
    | MergeCart (List CartEntry) (Maybe String)
    | UpdateCart
    | Receive (FetchState Bool)


init : Model
init =
    Model Nothing []


update : Msg -> Nav.Key -> Model -> (Msg -> msg) -> (Msg -> Cmd msg) -> ( Model, Cmd msg )
update msg key model wrapMsg sessionCmd =
    case msg of
        Login user path ->
            ( Model (Just user) (mergeCart model.shoppingCart user.shoppingCart)
            , Cmd.batch [ Nav.pushUrl key path, sessionCmd UpdateCart ]
            )

        Logout path ->
            ( { model | user = Nothing, shoppingCart = [] }
            , Nav.replaceUrl key path
            )

        Update user ->
            ( { model | user = Just user }, Cmd.none )

        MergeCart cart maybePath ->
            ( { model | shoppingCart = CartEntry.mergeCart model.shoppingCart cart }
            , Cmd.batch [ pushCmd key maybePath, sessionCmd UpdateCart ]
            )

        UpdateCart ->
            ( model, Cmd.map wrapMsg (updateCart model) )

        Receive _ ->
            ( model, Cmd.none )


pushCmd : Nav.Key -> Maybe String -> Cmd msg
pushCmd key maybePath =
    case maybePath of
        Just path ->
            Nav.pushUrl key path

        _ ->
            Cmd.none


mergeCart : List CartEntry -> String -> List CartEntry
mergeCart shoppingCart json =
    case Decode.decodeString (Decode.list CartEntry.decoder) json of
        Ok cart ->
            CartEntry.mergeCart shoppingCart cart

        Err _ ->
            shoppingCart


updateCart : Model -> Cmd Msg
updateCart { user, shoppingCart } =
    case user of
        Just { token } ->
            Fetch.putWithToken Receive Decode.bool token (Config.userApi ++ "/shoppingCart") <|
                let
                    json =
                        Encode.encode 0 (CartEntry.encodeCart shoppingCart)
                in
                Encode.object [ ( "shoppingCart", Encode.string json ) ]

        _ ->
            Cmd.none
