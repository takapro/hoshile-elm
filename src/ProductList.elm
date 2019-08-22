module ProductList exposing (productList)

import Bootstrap.Button as Button
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import FetchState exposing (FetchState(..))
import Html exposing (div, h4, h6, text)
import Html.Attributes exposing (class, src)
import Product exposing (Product)


productList : FetchState (List Product) -> Html.Html msg
productList state =
    Grid.container [ class "py-4" ]
        [ Grid.row []
            (case state of
                FetchNone ->
                    [ Grid.col [] [ text "None" ] ]

                FetchLoading ->
                    [ Grid.col [] [ text "Loading..." ] ]

                FetchSuccess list ->
                    List.map (\product -> Grid.col [ Col.md4 ] [ productCard product ]) list

                FetchFailed message ->
                    [ Grid.col [] [ text message ] ]
            )
        ]


productCard : Product -> Html.Html msg
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
                Button.button
                    [ Button.secondary
                    , Button.attrs [ class "float-right stretched-link" ]
                    ]
                    [ text "Detail" ]
            ]
        |> Card.view
