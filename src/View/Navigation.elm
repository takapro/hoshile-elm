module View.Navigation exposing (view)

import Bootstrap.Button as Button
import Bootstrap.Navbar as Navbar
import Html exposing (Html, text)
import Html.Attributes exposing (class)
import Shared exposing (Shared)
import Util.NavUtil exposing (href)


view : Shared t -> (Navbar.State -> msg) -> Html msg
view { config, session, navState } navMsg =
    Navbar.config navMsg
        |> Navbar.withAnimation
        |> Navbar.collapseSmall
        |> Navbar.dark
        |> Navbar.attrs [ class "text-light" ]
        |> Navbar.brand [ href config.nav "/" ] [ text config.title ]
        |> Navbar.items
            (List.append
                [ Navbar.itemLink [ href config.nav "/" ] [ text "Home" ]
                , Navbar.itemLink [ href config.nav "/about" ] [ text "About" ]
                ]
                (case session.user of
                    Nothing ->
                        [ Navbar.itemLink [ href config.nav "/login" ] [ text "Log in" ]
                        , Navbar.itemLink [ href config.nav "/signup" ] [ text "Sign up" ]
                        ]

                    Just user ->
                        [ Navbar.dropdown
                            { id = "navbar-dropdown"
                            , toggle = Navbar.dropdownToggle [] [ text user.name ]
                            , items =
                                [ Navbar.dropdownItem [ href config.nav "/profile" ] [ text "Profile" ]
                                , Navbar.dropdownItem [ href config.nav "/orderList" ] [ text "Order History" ]
                                , Navbar.dropdownDivider
                                , Navbar.dropdownItem [ href config.nav "/logout" ] [ text "Log out" ]
                                ]
                            }
                        ]
                )
            )
        |> Navbar.customItems
            [ Navbar.formItem []
                [ Button.linkButton
                    (if session.shoppingCart /= [] then
                        [ Button.warning
                        , Button.attrs [ href config.nav "/shoppingCart" ]
                        ]

                     else
                        [ Button.secondary
                        , Button.attrs [ href config.nav "/shoppingCart", class "text-white-50" ]
                        ]
                    )
                    [ text "Cart" ]
                ]
            ]
        |> Navbar.view navState
