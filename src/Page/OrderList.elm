module Page.OrderList exposing (Model, Msg, init, update, view)

import Bootstrap.Grid as Grid
import Bootstrap.Table as Table exposing (rowAttr)
import Entity.Order as Order exposing (OrderHead)
import Html exposing (Html, h3, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Json.Decode as Decode
import Shared exposing (Shared)
import Util.Api as Api
import Util.Fetch as Fetch exposing (FetchState(..))
import Util.NavUtil as NavUtil
import View.CustomAlert as CustomAlert


type alias Model =
    Maybe (FetchState (List OrderHead))


type Msg
    = Receive (FetchState (List OrderHead))
    | Detail Int


init : Shared t -> ( Model, Cmd Msg )
init shared =
    case shared.session.user of
        Just { token } ->
            ( Just Loading
            , Fetch.getWithToken Receive (Decode.list Order.decoder) token (Api.orders shared.config)
            )

        Nothing ->
            ( Nothing, Cmd.none )


update : Msg -> Shared t -> Model -> ( Model, Cmd Msg )
update msg shared model =
    case msg of
        Receive fetchState ->
            ( Just fetchState, Cmd.none )

        Detail id ->
            ( model, NavUtil.push shared.config.nav ("/order/" ++ String.fromInt id) )


view : Shared t -> Model -> Html Msg
view shared model =
    Grid.container [ class "py-4" ]
        (CustomAlert.maybeFetchState "Not logged in." "Fetch" model <|
            \orders ->
                [ h3 [ class "mb-3" ] [ text "Order History" ]
                , orderTable orders
                ]
        )


orderTable : List OrderHead -> Html Msg
orderTable orders =
    Table.table
        { options = [ Table.hover ]
        , thead =
            Table.simpleThead
                [ Table.th [] [ text "Date" ]
                , Table.th [] [ text "#Items" ]
                , Table.th [] [ text "Total Price" ]
                ]
        , tbody =
            Table.tbody [] (List.map orderRow orders)
        }


orderRow : OrderHead -> Table.Row Msg
orderRow { id, createDate, details } =
    Table.tr [ rowAttr (onClick (Detail id)) ]
        [ Table.td [] [ text createDate ]
        , Table.td [] [ text (String.fromInt (List.length details)) ]
        , Table.td [] [ text ("$" ++ String.fromFloat (Order.totalPrice details)) ]
        ]
