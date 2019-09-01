module View.Navigation exposing (view)

import Bootstrap.Button as Button
import Bootstrap.Navbar as Navbar
import Config
import Html exposing (Html, text)
import Html.Attributes exposing (class)
import Session
import Util.NavUtil as NavUtil


view : NavUtil.Model -> Session.Model -> Navbar.State -> (Navbar.State -> msg) -> Html msg
view nav session navState navMsg =
    Navbar.config navMsg
        |> Navbar.withAnimation
        |> Navbar.collapseSmall
        |> Navbar.dark
        |> Navbar.attrs [ class "text-light" ]
        |> Navbar.brand [ NavUtil.href nav "/" ] [ text Config.title ]
        |> Navbar.items
            (List.append
                [ Navbar.itemLink [ NavUtil.href nav "/" ] [ text "Home" ]
                , Navbar.itemLink [ NavUtil.href nav "/about" ] [ text "About" ]
                ]
                (case session.user of
                    Nothing ->
                        [ Navbar.itemLink [ NavUtil.href nav "/login" ] [ text "Log in" ]
                        , Navbar.itemLink [ NavUtil.href nav "/signup" ] [ text "Sign up" ]
                        ]

                    Just user ->
                        [ Navbar.dropdown
                            { id = "navbar-dropdown"
                            , toggle = Navbar.dropdownToggle [] [ text user.name ]
                            , items =
                                [ Navbar.dropdownItem [ NavUtil.href nav "/profile" ] [ text "Profile" ]
                                , Navbar.dropdownItem [ NavUtil.href nav "/orderList" ] [ text "Order History" ]
                                , Navbar.dropdownDivider
                                , Navbar.dropdownItem [ NavUtil.href nav "/logout" ] [ text "Log out" ]
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
                        , Button.attrs [ NavUtil.href nav "/shoppingCart" ]
                        ]

                     else
                        [ Button.secondary
                        , Button.attrs [ NavUtil.href nav "/shoppingCart", class "text-white-50" ]
                        ]
                    )
                    [ text "Cart" ]
                ]
            ]
        |> Navbar.view navState
