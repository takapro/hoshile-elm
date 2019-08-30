module Page.ProductList exposing (Model, Msg, init, update, view)

import Bootstrap.Button as Button
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Config
import Entity.Product as Product exposing (Product)
import Html exposing (Html, div, h4, h6, text)
import Html.Attributes exposing (class, href, src)
import Json.Decode exposing (list)
import Util.Fetch as Fetch exposing (FetchState(..))
import View.CustomAlert as CustomAlert


type alias Model =
    FetchState (List Product)


type Msg
    = Receive (FetchState (List Product))


init : ( Model, Cmd Msg )
init =
    ( Loading
    , Fetch.get Receive (list Product.decoder) Config.productApi
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg _ =
    case msg of
        Receive fetchState ->
            ( fetchState, Cmd.none )


view : Model -> Html Msg
view model =
    Grid.container [ class "py-4" ]
        (CustomAlert.fetchState "Fetch" model <|
            \products ->
                [ Grid.row []
                    (products
                        |> List.map (\product -> Grid.col [ Col.md4 ] [ productCard product ])
                    )
                ]
        )


productCard : Product -> Html msg
productCard product =
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
                        [ href ("/product/" ++ String.fromInt product.id)
                        , class "stretched-link"
                        ]
                    ]
                    [ text "Detail" ]
            ]
        |> Card.view
