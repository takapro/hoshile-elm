module Page.NotFound exposing (view)

import Bootstrap.Alert as Alert
import Bootstrap.Grid as Grid
import Html exposing (Html, text)
import Html.Attributes exposing (class)


view : Html msg
view =
    Grid.container [ class "py-4" ]
        [ Alert.simpleDanger []
            [ text "Page Not Found" ]
        ]
