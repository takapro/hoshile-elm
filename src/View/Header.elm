module View.Header exposing (view)

import Bootstrap.Grid as Grid
import Config exposing (Config)
import Html exposing (Html, a, h1, header, text)
import Html.Attributes exposing (class)
import Util.NavUtil exposing (href)


view : Config -> Html msg
view { title, nav } =
    header [ class "py-4" ]
        [ Grid.container [ class "text-center" ]
            [ h1 []
                [ a [ href nav "/" ] [ text (title ++ " (Elm)") ] ]
            ]
        ]
