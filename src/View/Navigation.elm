module View.Navigation exposing (view)

import Bootstrap.Button as Button
import Bootstrap.Navbar as Navbar
import Config exposing (Config)
import Html exposing (Html, text)
import Html.Attributes exposing (class)
import Session
import Util.NavUtil exposing (href)


view : Config -> Session.Model -> Navbar.State -> (Navbar.State -> msg) -> Html msg
view { title, nav } session navState navMsg =
    Navbar.config navMsg
        |> Navbar.withAnimation
        |> Navbar.collapseSmall
        |> Navbar.dark
        |> Navbar.attrs [ class "text-light" ]
        |> Navbar.brand [ href nav "/" ] [ text title ]
        |> Navbar.items
            (List.append
                [ Navbar.itemLink [ href nav "/" ] [ text "Home" ]
                , Navbar.itemLink [ href nav "/about" ] [ text "About" ]
                ]
                (case session.user of
                    Nothing ->
                        [ Navbar.itemLink [ href nav "/login" ] [ text "Log in" ]
                        , Navbar.itemLink [ href nav "/signup" ] [ text "Sign up" ]
                        ]

                    Just user ->
                        [ Navbar.dropdown
                            { id = "navbar-dropdown"
                            , toggle = Navbar.dropdownToggle [] [ text user.name ]
                            , items =
                                [ Navbar.dropdownItem [ href nav "/profile" ] [ text "Profile" ]
                                , Navbar.dropdownItem [ href nav "/orderList" ] [ text "Order History" ]
                                , Navbar.dropdownDivider
                                , Navbar.dropdownItem [ href nav "/logout" ] [ text "Log out" ]
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
                        , Button.attrs [ href nav "/shoppingCart" ]
                        ]

                     else
                        [ Button.secondary
                        , Button.attrs [ href nav "/shoppingCart", class "text-white-50" ]
                        ]
                    )
                    [ text "Cart" ]
                ]
            ]
        |> Navbar.view navState
