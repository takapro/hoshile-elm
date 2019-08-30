module Page.NotFound exposing (view)

import Bootstrap.Grid as Grid
import Html exposing (Html)
import Html.Attributes exposing (class)
import View.CustomAlert as CustomAlert


view : Html msg
view =
    Grid.container [ class "py-4" ]
        [ CustomAlert.error "Page Not Found" ]
