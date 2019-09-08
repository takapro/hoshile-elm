module Page.ProductList exposing (Model, Msg, init, update, view)

import Bootstrap.Button as Button
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Entity.Product as Product exposing (Product)
import Html exposing (Html, div, h4, h6, text)
import Html.Attributes exposing (class, src)
import Json.Decode as Decode
import Return exposing (Return, return, withCmd)
import Shared exposing (Shared)
import Util.Api as Api
import Util.Fetch as Fetch exposing (FetchState(..))
import Util.NavUtil exposing (href)
import View.CustomAlert as CustomAlert


type alias Model =
    FetchState (List Product)


type Msg
    = Receive (FetchState (List Product))
    | Reload


init : Shared t -> Return Model Msg msg
init { config } =
    return Loading
        |> withCmd (Fetch.get Receive (Decode.list Product.decoder) (Api.products config))


update : Msg -> Shared t -> Model -> Return Model Msg msg
update msg shared _ =
    case msg of
        Receive fetchState ->
            return fetchState

        Reload ->
            init shared


view : Shared t -> Model -> Html Msg
view shared model =
    Grid.container [ class "py-4" ]
        (CustomAlert.fetchState "Fetch" model Reload <|
            \products ->
                [ Grid.row []
                    (products
                        |> List.map (\product -> Grid.col [ Col.md4 ] [ productCard shared product ])
                    )
                ]
        )


productCard : Shared t -> Product -> Html msg
productCard { config } product =
    Card.config [ Card.attrs [ class "mb-3" ] ]
        |> Card.imgTop [ src product.imageUrl, class "img-fluid" ] []
        |> Card.block
            [ Block.attrs [ class "d-flex justify-content-between align-items-end" ] ]
            [ Block.custom <|
                div []
                    [ h6 [ class "card-title mb-1" ] [ text product.brand ]
                    , h4 [ class "card-title mb-0" ] [ text product.name ]
                    ]
            , Block.custom <|
                Button.linkButton
                    [ Button.secondary
                    , Button.attrs
                        [ href config ("/product/" ++ String.fromInt product.id)
                        , class "stretched-link"
                        ]
                    ]
                    [ text "Detail" ]
            ]
        |> Card.view
