module Page.ProductList exposing (Model, Msg, init, update, view)

import Bootstrap.Button as Button
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Config exposing (Config)
import Entity.Product as Product exposing (Product)
import Html exposing (Html, div, h4, h6, text)
import Html.Attributes exposing (class, src)
import Json.Decode as Decode
import Util.Api as Api
import Util.Fetch as Fetch exposing (FetchState(..))
import Util.NavUtil exposing (href)
import View.CustomAlert as CustomAlert


type alias Model =
    FetchState (List Product)


type Msg
    = Receive (FetchState (List Product))


init : Config -> ( Model, Cmd Msg )
init config =
    ( Loading
    , Fetch.get Receive (Decode.list Product.decoder) (Api.products config)
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg _ =
    case msg of
        Receive fetchState ->
            ( fetchState, Cmd.none )


view : Config -> Model -> Html Msg
view config model =
    Grid.container [ class "py-4" ]
        (CustomAlert.fetchState "Fetch" model <|
            \products ->
                [ Grid.row []
                    (products
                        |> List.map (\product -> Grid.col [ Col.md4 ] [ productCard config product ])
                    )
                ]
        )


productCard : Config -> Product -> Html msg
productCard { nav } product =
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
                        [ href nav ("/product/" ++ String.fromInt product.id)
                        , class "stretched-link"
                        ]
                    ]
                    [ text "Detail" ]
            ]
        |> Card.view
