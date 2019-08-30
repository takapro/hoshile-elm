module Navigation exposing (storeFooter, storeHeader, storeNav)

import Bootstrap.Button as Button
import Bootstrap.Grid as Grid
import Bootstrap.Navbar as Navbar
import Config
import Html exposing (Html, a, br, footer, h1, header, p, small, text)
import Html.Attributes exposing (class, href)
import Session


storeHeader : Html msg
storeHeader =
    header [ class "py-4" ]
        [ Grid.container [ class "text-center" ]
            [ h1 []
                [ a [ href "/" ] [ text Config.title ] ]
            ]
        ]


storeNav : Session.Model -> Navbar.State -> (Navbar.State -> msg) -> Html msg
storeNav session navState navMsg =
    Navbar.config navMsg
        |> Navbar.withAnimation
        |> Navbar.collapseSmall
        |> Navbar.dark
        |> Navbar.attrs [ class "text-light" ]
        |> Navbar.brand [ href "/" ] [ text Config.title ]
        |> Navbar.items
            (List.append
                [ Navbar.itemLink [ href "/" ] [ text "Home" ]
                , Navbar.itemLink [ href "#" ] [ text "About" ]
                ]
                (case session.user of
                    Nothing ->
                        [ Navbar.itemLink [ href "/login" ] [ text "Log in" ]
                        , Navbar.itemLink [ href "/signup" ] [ text "Sign up" ]
                        ]

                    Just user ->
                        [ Navbar.dropdown
                            { id = "navbar-dropdown"
                            , toggle = Navbar.dropdownToggle [] [ text user.name ]
                            , items =
                                [ Navbar.dropdownItem [ href "/profile" ] [ text "Profile" ]
                                , Navbar.dropdownItem [ href "#" ] [ text "Order History" ]
                                , Navbar.dropdownDivider
                                , Navbar.dropdownItem [ href "/logout" ] [ text "Log out" ]
                                ]
                            }
                        ]
                )
            )
        |> Navbar.customItems
            [ Navbar.formItem []
                [ Button.button [ Button.warning ] [ text "Cart" ]
                ]
            ]
        |> Navbar.view navState


storeFooter : Html msg
storeFooter =
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
