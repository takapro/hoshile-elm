module Session exposing (Msg(..), Session, init, update)

import Config exposing (Config)
import Entity.CartEntry as CartEntry exposing (CartEntry)
import Entity.User exposing (User)
import Json.Decode as Decode
import Json.Encode as Encode
import Return exposing (Return, return, withCmd, withSessionMsg)
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


update : Msg -> Config -> Session -> Return Session Msg Msg
update msg config session =
    case msg of
        Login user path ->
            return (Session (Just user) (mergeCart session.shoppingCart user.shoppingCart))
                |> withCmd (NavUtil.push config.nav path)
                |> withSessionMsg UpdateCart

        Logout path ->
            return { session | user = Nothing, shoppingCart = [] }
                |> withCmd (NavUtil.replace config.nav path)

        Update user ->
            return { session | user = Just user }

        MergeCart cart maybePath ->
            return { session | shoppingCart = CartEntry.mergeCart session.shoppingCart cart }
                |> withCmd (pushCmd config maybePath)
                |> withSessionMsg UpdateCart

        UpdateCart ->
            return session
                |> withCmd (updateCart config session)

        Receive _ ->
            return session


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
