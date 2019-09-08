module Page.ShoppingCart exposing (Model, Msg, init, update, view)

import Bootstrap.Button as Button exposing (attrs, disabled, large, light, onClick, primary, small)
import Bootstrap.Grid as Grid
import Bootstrap.Table as Table exposing (cellAttr)
import Entity.CartEntry as CartEntry exposing (CartEntry, DetailEntry)
import Entity.Product as Product exposing (Product)
import Html exposing (Html, div, h3, img, span, text)
import Html.Attributes exposing (class, colspan, src)
import Json.Decode as Decode
import Return exposing (Return, return, withCmd, withSessionMsg)
import Session
import Shared exposing (Shared)
import Util.Api as Api
import Util.Fetch as Fetch exposing (FetchState(..))
import Util.ListUtil as ListUtil
import Util.NavUtil as NavUtil
import View.CustomAlert as CustomAlert


type alias Model =
    { fetchState : FetchState (List Product)
    , purchaseState : Maybe (FetchState Int)
    }


type Msg
    = Receive (FetchState (List Product))
    | Reload
    | Quantity Int Int
    | Purchase
    | ReceivePurchase (FetchState Int)


init : Shared t -> Return Model Msg msg
init { config } =
    return (Model Loading Nothing)
        |> withCmd (Fetch.get Receive (Decode.list Product.decoder) (Api.products config))


update : Msg -> Shared t -> Model -> Return Model Msg Session.Msg
update msg ({ config, session } as shared) model =
    case msg of
        Receive fetchState ->
            return { model | fetchState = fetchState }

        Reload ->
            init shared

        Quantity id delta ->
            return model
                |> withSessionMsg (Session.MergeCart [ CartEntry id delta ])

        Purchase ->
            case session.user of
                Just { token } ->
                    return { model | purchaseState = Just Loading }
                        |> withCmd (purchaseCmd shared token)

                Nothing ->
                    return model
                        |> withCmd (NavUtil.push config "/login?forPurchase=true")

        ReceivePurchase (Success orderId) ->
            return model
                |> withCmd (NavUtil.push config ("/orders/" ++ String.fromInt orderId))

        ReceivePurchase purchaseState ->
            return { model | purchaseState = Just purchaseState }


cantPurchase : Shared t -> Bool
cantPurchase { session } =
    session.user /= Nothing && session.shoppingCart == []


purchaseCmd : Shared t -> String -> Cmd Msg
purchaseCmd { config, session } token =
    Fetch.postWithToken ReceivePurchase Decode.int token (Api.orders config) <|
        CartEntry.encodeCart session.shoppingCart


view : Shared t -> Model -> Html Msg
view ({ session } as shared) model =
    Grid.container [ class "py-4" ]
        (CustomAlert.fetchState "Fetch" model.fetchState Reload <|
            \products -> cartView shared model (CartEntry.joinProducts session.shoppingCart products)
        )


cartView : Shared t -> Model -> List DetailEntry -> List (Html Msg)
cartView ({ session } as shared) model entries =
    ListUtil.append3
        [ h3 [ class "mb-3" ] [ text "Shopping Cart" ]
        ]
        (CustomAlert.errorIfFailure "Purchase" model.purchaseState)
        [ cartTable entries
        , div [ class "text-center" ]
            [ Button.button
                [ primary, large, attrs [ class "w-25" ], onClick Purchase, disabled (cantPurchase shared) ]
                (CustomAlert.spinnerLabel model.purchaseState <|
                    if session.user /= Nothing then
                        "Purchase"

                    else
                        "Please Log in"
                )
            ]
        ]


cartTable : List DetailEntry -> Html Msg
cartTable entries =
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
                    (List.map cartRow entries)
                    [ Table.tr []
                        [ Table.td [ cellAttr (colspan 4) ] []
                        , Table.th [] [ text "Total" ]
                        , Table.td [] [ text ("$" ++ String.fromFloat (CartEntry.totalPrice entries)) ]
                        ]
                    ]
                )
        }


cartRow : DetailEntry -> Table.Row Msg
cartRow { product, quantity } =
    Table.tr []
        [ Table.td [ cellAttr (class "w-25") ]
            [ img [ src product.imageUrl, class "img-fluid w-75" ] []
            ]
        , Table.td [] [ text product.brand ]
        , Table.td [] [ text product.name ]
        , Table.td []
            [ Button.button
                [ light, small, onClick (Quantity product.id -1) ]
                [ text "-" ]
            , span [ class "mx-2" ] [ text (String.fromInt quantity) ]
            , Button.button
                [ light, small, onClick (Quantity product.id 1) ]
                [ text "+" ]
            ]
        , Table.td [] [ text ("$" ++ String.fromFloat product.price) ]
        , Table.td [] [ text ("$" ++ String.fromFloat (product.price * toFloat quantity)) ]
        ]
