module View.Navigation exposing (view)

import Bootstrap.Button as Button
import Bootstrap.Navbar as Navbar
import Config
import Html exposing (Html, text)
import Html.Attributes exposing (class, href)
import Session


view : Session.Model -> Navbar.State -> (Navbar.State -> msg) -> Html msg
view session navState navMsg =
    Navbar.config navMsg
        |> Navbar.withAnimation
        |> Navbar.collapseSmall
        |> Navbar.dark
        |> Navbar.attrs [ class "text-light" ]
        |> Navbar.brand [ href "/" ] [ text Config.title ]
        |> Navbar.items
            (List.append
                [ Navbar.itemLink [ href "/" ] [ text "Home" ]
                , Navbar.itemLink [ href "/about" ] [ text "About" ]
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
                                , Navbar.dropdownItem [ href "/orderList" ] [ text "Order History" ]
                                , Navbar.dropdownDivider
                                , Navbar.dropdownItem [ href "/logout" ] [ text "Log out" ]
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
                        , Button.attrs [ href "/shoppingCart" ]
                        ]

                     else
                        [ Button.secondary
                        , Button.attrs [ href "/shoppingCart", class "text-white-50" ]
                        ]
                    )
                    [ text "Cart" ]
                ]
            ]
        |> Navbar.view navState
