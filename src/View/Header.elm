module View.Header exposing (view)

import Bootstrap.Grid as Grid
import Html exposing (Html, a, h1, header, text)
import Html.Attributes exposing (class)
import Shared exposing (Shared)
import Util.NavUtil exposing (href)


view : Shared t -> Html msg
view { config } =
    header [ class "py-4" ]
        [ Grid.container [ class "text-center" ]
            [ h1 []
                [ a [ href config "/" ] [ text (config.title ++ " (Elm)") ] ]
            ]
        ]
