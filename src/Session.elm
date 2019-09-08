module Session exposing (Msg(..), Session, init, update)

import Config exposing (Config)
import Entity.CartEntry as CartEntry exposing (CartEntry)
import Entity.User exposing (User)
import Json.Decode as Decode
import Json.Encode as Encode
import Return exposing (Return, return, withCmd, withSessionMsg)
import Util.Api as Api
import Util.Fetch as Fetch exposing (FetchState(..))


type alias Session =
    { user : Maybe User
    , shoppingCart : List CartEntry
    }


type Msg
    = Login User
    | Logout
    | Update User
    | MergeCart (List CartEntry)
    | UpdateCart
    | Receive (FetchState Bool)


init : Session
init =
    Session Nothing []


update : Msg -> Config -> Session -> Return Session Msg Msg
update msg config session =
    case msg of
        Login user ->
            return (Session (Just user) (mergeCart session.shoppingCart user.shoppingCart))
                |> withSessionMsg UpdateCart

        Logout ->
            return { session | user = Nothing, shoppingCart = [] }

        Update user ->
            return { session | user = Just user }

        MergeCart cart ->
            return { session | shoppingCart = CartEntry.mergeCart session.shoppingCart cart }
                |> withSessionMsg UpdateCart

        UpdateCart ->
            return session
                |> withCmd (updateCart config session)

        Receive _ ->
            return session


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
