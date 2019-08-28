module Page.ProductList exposing (Model, Msg, init, update, view)

import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Config
import Html exposing (Html, a, div, h4, h6, text)
import Html.Attributes exposing (class, href, src)
import Http
import Json.Decode exposing (list)
import Product exposing (Product)


type Model
    = Loading
    | Success (List Product)
    | Failed String


type Msg
    = Receive (Result Http.Error (List Product))


init : ( Model, Cmd Msg )
init =
    ( Loading
    , Http.get
        { url = Config.productApi
        , expect = Http.expectJson Receive (list Product.decoder)
        }
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Receive (Ok result) ->
            ( Success result, Cmd.none )

        Receive (Err error) ->
            ( Failed (Debug.toString error), Cmd.none )


view : Model -> Html Msg
view model =
    Grid.container [ class "py-4" ]
        [ Grid.row []
            (case model of
                Loading ->
                    [ Grid.col [] [ text "Loading..." ] ]

                Success list ->
                    List.map (\product -> Grid.col [ Col.md4 ] [ productCard product ]) list

                Failed message ->
                    [ Grid.col [] [ text message ] ]
            )
        ]


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
                a
                    [ href ("/product/" ++ String.fromInt product.id)
                    , class "btn btn-secondary stretched-link"
                    ]
                    [ text "Detail" ]
            ]
        |> Card.view
