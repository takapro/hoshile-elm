module Page.ShoppingCart exposing (Model, Msg, init, update, view)

import Bootstrap.Button as Button exposing (attrs, disabled, large, light, onClick, primary, small)
import Bootstrap.Grid as Grid
import Bootstrap.Table as Table exposing (cellAttr)
import Browser.Navigation as Nav
import Config
import Entity.CartEntry as CartEntry exposing (CartEntry, DetailEntry)
import Entity.Product as Product exposing (Product)
import Html exposing (Html, div, h3, img, span, text)
import Html.Attributes exposing (class, colspan, src)
import Json.Decode as Decode
import Session
import Util.Fetch as Fetch exposing (FetchState(..))
import Util.ListUtil as ListUtil
import View.CustomAlert as CustomAlert


type alias Model =
    { token : Maybe String
    , fetchState : FetchState (List Product)
    , purchaseState : Maybe (FetchState Int)
    }


type Msg
    = Receive (FetchState (List Product))
    | Quantity Int Int
    | Purchase
    | ReceivePurchase (FetchState Int)


init : Session.Model -> ( Model, Cmd Msg )
init { user } =
    ( Model (Maybe.map .token user) Loading Nothing
    , Fetch.get Receive (Decode.list Product.decoder) Config.productApi
    )


update : Msg -> Nav.Key -> Session.Model -> Model -> (Msg -> msg) -> (Session.Msg -> Cmd msg) -> ( Model, Cmd msg )
update msg key { shoppingCart } model wrapMsg sessionCmd =
    case msg of
        Receive fetchState ->
            ( { model | fetchState = fetchState }, Cmd.none )

        Quantity id delta ->
            ( model, sessionCmd (Session.MergeCart [ CartEntry id delta ] Nothing) )

        Purchase ->
            case model.token of
                Just token ->
                    ( { model | purchaseState = Just Loading }
                    , Cmd.map wrapMsg (purchaseCmd token shoppingCart)
                    )

                Nothing ->
                    ( model, Nav.pushUrl key "/login?forPurchase=true" )

        ReceivePurchase (Success orderId) ->
            ( model, Nav.pushUrl key ("/orders/" ++ String.fromInt orderId) )

        ReceivePurchase purchaseState ->
            ( { model | purchaseState = Just purchaseState }, Cmd.none )


cantPurchase : Session.Model -> Model -> Bool
cantPurchase { shoppingCart } { token } =
    token /= Nothing && shoppingCart == []


purchaseCmd : String -> List CartEntry -> Cmd Msg
purchaseCmd token shoppingCart =
    Fetch.postWithToken ReceivePurchase Decode.int token Config.orderApi <|
        CartEntry.encodeCart shoppingCart


view : Session.Model -> Model -> Html Msg
view session model =
    Grid.container [ class "py-4" ]
        (CustomAlert.fetchState "Fetch" model.fetchState <|
            \products -> cartView session model (CartEntry.joinProducts session.shoppingCart products)
        )


cartView : Session.Model -> Model -> List DetailEntry -> List (Html Msg)
cartView session model entries =
    ListUtil.append3
        [ h3 [ class "mb-3" ] [ text "Shopping Cart" ]
        ]
        (CustomAlert.errorIfFailure "Purchase" model.purchaseState)
        [ cartTable entries
        , div [ class "text-center" ]
            [ Button.button
                [ primary, large, attrs [ class "w-25" ], onClick Purchase, disabled (cantPurchase session model) ]
                (CustomAlert.spinnerLabel model.purchaseState <|
                    if model.token /= Nothing then
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
