module View.Header exposing (view)

import Bootstrap.Grid as Grid
import Config
import Html exposing (Html, a, h1, header, text)
import Html.Attributes exposing (class)
import Util.NavUtil as NavUtil


view : NavUtil.Model -> Html msg
view nav =
    header [ class "py-4" ]
        [ Grid.container [ class "text-center" ]
            [ h1 []
                [ a [ NavUtil.href nav "/" ] [ text Config.title ] ]
            ]
        ]
