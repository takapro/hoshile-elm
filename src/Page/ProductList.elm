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
import Shared exposing (Shared)
import Util.Api as Api
import Util.Fetch as Fetch exposing (FetchState(..))
import Util.NavUtil exposing (href)
import View.CustomAlert as CustomAlert


type alias Model =
    FetchState (List Product)


type Msg
    = Receive (FetchState (List Product))


init : Shared t -> ( Model, Cmd Msg )
init shared =
    ( Loading
    , Fetch.get Receive (Decode.list Product.decoder) (Api.products shared.config)
    )


update : Msg -> Shared t -> Model -> ( Model, Cmd Msg )
update msg shared model =
    case msg of
        Receive fetchState ->
            ( fetchState, Cmd.none )


view : Shared t -> Model -> Html Msg
view shared model =
    Grid.container [ class "py-4" ]
        (CustomAlert.fetchState "Fetch" model <|
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
                        [ href config.nav ("/product/" ++ String.fromInt product.id)
                        , class "stretched-link"
                        ]
                    ]
                    [ text "Detail" ]
            ]
        |> Card.view
