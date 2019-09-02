module Page.OrderDetail exposing (Model, Msg, init, update, view)

import Bootstrap.Grid as Grid
import Bootstrap.Table as Table exposing (cellAttr)
import Entity.Order as Order exposing (OrderDetail, OrderHead)
import Html exposing (Html, h3, img, p, text)
import Html.Attributes exposing (class, colspan, src)
import Return exposing (Return, return, withCmd)
import Shared exposing (Shared)
import Util.Api as Api
import Util.Fetch as Fetch exposing (FetchState(..))
import View.CustomAlert as CustomAlert


type alias Model =
    Maybe (FetchState OrderHead)


type Msg
    = Receive (FetchState OrderHead)


init : Shared t -> Int -> Return Model Msg msg
init { config, session } id =
    case session.user of
        Just { token } ->
            return (Just Loading)
                |> withCmd (Fetch.getWithToken Receive Order.decoder token (Api.order config id))

        Nothing ->
            return Nothing


update : Msg -> Shared t -> Model -> Return Model Msg msg
update msg _ _ =
    case msg of
        Receive fetchState ->
            return (Just fetchState)


view : Shared t -> Model -> Html Msg
view _ model =
    Grid.container [ class "py-4" ]
        (CustomAlert.maybeFetchState "Not logged in." "Fetch" model <|
            \order ->
                [ h3 [ class "mb-3" ] [ text "Order Detail" ]
                , p [ class "mb-3" ] [ text ("Date: " ++ order.createDate) ]
                , detailTable order.details
                ]
        )


detailTable : List OrderDetail -> Html Msg
detailTable details =
    Table.table
        { options = []
        , thead =
            Table.simpleThead
                [ Table.th [] [ text "Image" ]
                , Table.th [] [ text "Brand" ]
                , Table.th [] [ text "Name" ]
                , Table.th [] [ text "Quantity" ]
                , Table.th [] [ text "Unit Price" ]
                , Table.th [] [ text "Price" ]
                ]
        , tbody =
            Table.tbody []
                (List.append
                    (List.map detailRow details)
                    [ Table.tr []
                        [ Table.td [ cellAttr (colspan 4) ] []
                        , Table.th [] [ text "Total" ]
                        , Table.td [] [ text ("$" ++ String.fromFloat (Order.totalPrice details)) ]
                        ]
                    ]
                )
        }


detailRow : OrderDetail -> Table.Row Msg
detailRow { product, quantity } =
    Table.tr []
        [ Table.td [ cellAttr (class "w-25") ]
            [ img [ src product.imageUrl, class "img-fluid w-75" ] []
            ]
        , Table.td [] [ text product.brand ]
        , Table.td [] [ text product.name ]
        , Table.td [] [ text (String.fromInt quantity) ]
        , Table.td [] [ text ("$" ++ String.fromFloat product.price) ]
        , Table.td [] [ text ("$" ++ String.fromFloat (product.price * toFloat quantity)) ]
        ]
