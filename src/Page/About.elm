module Page.About exposing (view)

import Bootstrap.Grid as Grid
import Html exposing (Html, h3, img, li, p, text, ul)
import Html.Attributes exposing (alt, class, src)


view : Html msg
view =
    Grid.container [ class "py-4" ]
        [ h3 [ class "text-center mb-3" ] [ text "CSIS-3280-002 HoshiLe Project" ]
        , p [] [ text "Student: Takanori Hoshi - 300306402" ]
        , p [] [ text "Student: Ngoc Tin Le – 300296440" ]
        , p [] [ text "Team name: HoshiLe" ]
        , p [] [ text "Meeting minutes: Thursday – from 3:00-4:00" ]
        , p [] [ text "Project is an online computer store (HoshiLe’s store)" ]
        , p [] [ text "+ Create a repository on GitHub" ]
        , p [] [ text "+ Entities: Product, Orders, Order Details, User (Shopping Cart)" ]
        , p [] [ text "+ Web services:" ]
        , ul []
            [ li [] [ text "CRUD for the Product" ]
            , li [] [ text "CRUD Orders (Order Details)" ]
            , li [] [ text "CRUD Users" ]
            , li [] [ text "Authentication for User" ]
            ]
        , p [] [ text "Store Front page / Admin page" ]
        , p [] [ img [ class "img-fluid", src "img/ClassDiagram.png", alt "Class Diagram" ] [] ]
        ]
