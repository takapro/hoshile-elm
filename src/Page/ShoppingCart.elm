module Page.ShoppingCart exposing (Model, Msg, init, update, view)

import Bootstrap.Button as Button exposing (primary)
import Bootstrap.Grid as Grid
import Bootstrap.Table as Table exposing (cellAttr)
import Config
import Entity.CartEntry as CartEntry exposing (CartEntry, DetailEntry)
import Entity.Product as Product exposing (Product)
import Html exposing (Html, div, h3, img, text)
import Html.Attributes exposing (class, colspan, src)
import Json.Decode exposing (list)
import Util.Fetch as Fetch exposing (FetchState(..))
import View.CustomAlert as CustomAlert


type alias Model =
    { entries : List CartEntry
    , fetchState : FetchState (List Product)
    }


type Msg
    = Receive (FetchState (List Product))


init : List CartEntry -> ( Model, Cmd Msg )
init entries =
    ( Model entries Loading
    , Fetch.get Receive (list Product.decoder) Config.productApi
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Receive fetchState ->
            ( { model | fetchState = fetchState }, Cmd.none )


view : Model -> Html Msg
view model =
    Grid.container [ class "py-4" ]
        (CustomAlert.fetchState "Fetch" model.fetchState <|
            \products -> shoppingCart model (CartEntry.detailEntries model.entries products)
        )


shoppingCart : Model -> List DetailEntry -> List (Html msg)
shoppingCart model entries =
    [ h3 [ class "mb-3" ] [ text "Shopping Cart" ]
    , cartTable entries
    , div [ class "text-center" ]
        [ Button.button [ primary ] [ text "Purchase" ]
        ]
    ]


cartTable : List DetailEntry -> Html msg
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


cartRow : DetailEntry -> Table.Row msg
cartRow { product, quantity } =
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
