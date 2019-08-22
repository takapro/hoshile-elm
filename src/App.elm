module Main exposing (main)

import Bootstrap.Button as Button
import Bootstrap.Grid as Grid
import Bootstrap.Navbar as Navbar
import Browser
import FetchState exposing (FetchMsg(..), FetchState(..), updateFetch)
import Html exposing (a, br, div, footer, h1, header, p, small, text)
import Html.Attributes exposing (class, href)
import Product exposing (Product, fetchProductList)
import ProductList exposing (productList)


type alias Model =
    { navState : Navbar.State
    , productList : FetchState (List Product)
    }


type Msg
    = NavMsg Navbar.State
    | ProductListMsg (FetchMsg (List Product))


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }


init : () -> ( Model, Cmd Msg )
init () =
    let
        ( navState, navCmd ) =
            Navbar.initialState NavMsg
    in
    ( { navState = navState
      , productList = FetchNone
      }
    , Cmd.batch [ navCmd, fetchProductList ProductListMsg ]
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Navbar.subscriptions model.navState NavMsg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NavMsg state ->
            ( { model | navState = state }, Cmd.none )

        ProductListMsg fetchMsg ->
            let
                ( state, cmd ) =
                    updateFetch fetchMsg (fetchProductList ProductListMsg)
            in
            ( { model | productList = state }, cmd )


view : Model -> Html.Html Msg
view model =
    div []
        [ storeHeader
        , storeNav model
        , productList model.productList
        , storeFooter
        ]


storeHeader : Html.Html Msg
storeHeader =
    header [ class "py-4" ]
        [ Grid.container [ class "text-center" ]
            [ h1 []
                [ a [ href "/" ]
                    [ text "HoshiLe’s Store"
                    ]
                ]
            ]
        ]


storeNav : Model -> Html.Html Msg
storeNav model =
    Navbar.config NavMsg
        |> Navbar.withAnimation
        |> Navbar.collapseSmall
        |> Navbar.dark
        |> Navbar.attrs [ class "text-light" ]
        |> Navbar.brand [ href "#" ] [ text "HoshiLe’s Store" ]
        |> Navbar.items
            [ Navbar.itemLink [ href "#" ] [ text "Home" ]
            , Navbar.itemLink [ href "#" ] [ text "About" ]
            , Navbar.itemLink [ href "#" ] [ text "Log in" ]
            , Navbar.itemLink [ href "#" ] [ text "Sign up" ]
            , Navbar.dropdown
                { id = "navbar-dropdown"
                , toggle = Navbar.dropdownToggle [] [ text "username" ]
                , items =
                    [ Navbar.dropdownItem [ href "#" ] [ text "Profile" ]
                    , Navbar.dropdownItem [ href "#" ] [ text "Order History" ]
                    , Navbar.dropdownDivider
                    , Navbar.dropdownItem [ href "#" ] [ text "Log out" ]
                    ]
                }
            ]
        |> Navbar.customItems
            [ Navbar.formItem []
                [ Button.button [ Button.warning ] [ text "Cart" ]
                ]
            ]
        |> Navbar.view model.navState


storeFooter : Html.Html Msg
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
