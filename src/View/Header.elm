module View.Header exposing (view)

import Bootstrap.Grid as Grid
import Config
import Html exposing (Html, a, h1, header, text)
import Html.Attributes exposing (class, href)


view : Html msg
view =
    header [ class "py-4" ]
        [ Grid.container [ class "text-center" ]
            [ h1 []
                [ a [ href "/" ] [ text Config.title ] ]
            ]
        ]
