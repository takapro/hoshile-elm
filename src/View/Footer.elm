module View.Footer exposing (view)

import Bootstrap.Grid as Grid
import Html exposing (Html, a, br, footer, p, small, text)
import Html.Attributes exposing (class, href)


view : Html msg
view =
    footer [ class "py-4 bg-dark text-light" ]
        [ Grid.container [ class "text-center" ]
            [ p []
                [ small []
                    [ text "CSIS 3280 Project by Takanori Hoshi (300306402) and Ngoc Tin Le (300296440)"
                    , br [] []
                    , text "Design by "
                    , a [ href "https://gihyo.jp/book/2018/978-4-297-10020-9" ]
                        [ text "Bootstrap 4 Textbook of Frontend Development (Japanese)"
                        ]
                    ]
                ]
            ]
        ]
