module Session exposing (Msg(..), Session, init, update)

import Config exposing (Config)
import Entity.CartEntry as CartEntry exposing (CartEntry)
import Entity.User exposing (User)
import Json.Decode as Decode
import Json.Encode as Encode
import Util.Api as Api
import Util.Fetch as Fetch exposing (FetchState(..))
import Util.NavUtil as NavUtil


type alias Session =
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


init : Session
init =
    Session Nothing []


update : Msg -> Config -> Session -> (Msg -> msg) -> (Msg -> Cmd msg) -> ( Session, Cmd msg )
update msg config session wrapMsg sessionCmd =
    case msg of
        Login user path ->
            ( Session (Just user) (mergeCart session.shoppingCart user.shoppingCart)
            , Cmd.batch [ NavUtil.push config.nav path, sessionCmd UpdateCart ]
            )

        Logout path ->
            ( { session | user = Nothing, shoppingCart = [] }
            , NavUtil.replace config.nav path
            )

        Update user ->
            ( { session | user = Just user }, Cmd.none )

        MergeCart cart maybePath ->
            ( { session | shoppingCart = CartEntry.mergeCart session.shoppingCart cart }
            , Cmd.batch [ pushCmd config maybePath, sessionCmd UpdateCart ]
            )

        UpdateCart ->
            ( session, Cmd.map wrapMsg (updateCart config session) )

        Receive _ ->
            ( session, Cmd.none )


pushCmd : Config -> Maybe String -> Cmd msg
pushCmd config maybePath =
    case maybePath of
        Just path ->
            NavUtil.push config.nav path

        _ ->
            Cmd.none


mergeCart : List CartEntry -> String -> List CartEntry
mergeCart shoppingCart json =
    case Decode.decodeString (Decode.list CartEntry.decoder) json of
        Ok cart ->
            CartEntry.mergeCart shoppingCart cart

        Err _ ->
            shoppingCart


updateCart : Config -> Session -> Cmd Msg
updateCart config { user, shoppingCart } =
    case user of
        Just { token } ->
            Fetch.putWithToken Receive Decode.bool token (Api.user config "shoppingCart") <|
                let
                    json =
                        Encode.encode 0 (CartEntry.encodeCart shoppingCart)
                in
                Encode.object [ ( "shoppingCart", Encode.string json ) ]

        _ ->
            Cmd.none
