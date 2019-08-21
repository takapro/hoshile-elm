module Main exposing (main)

import Bootstrap.Button as Button
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Navbar as Navbar
import Browser
import Html exposing (a, br, div, footer, h1, h4, h6, header, img, p, small, text)
import Html.Attributes exposing (class, href, src)


type alias Model =
    { navState : Navbar.State
    }


type Msg
    = NavMsg Navbar.State


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
    ( { navState = navState }
    , Cmd.batch [ navCmd ]
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Navbar.subscriptions model.navState NavMsg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NavMsg state ->
            ( { model | navState = state }
            , Cmd.none
            )


view : Model -> Html.Html Msg
view model =
    div []
        [ storeHeader
        , storeNav model
        , productList
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


productList : Html.Html Msg
productList =
    Grid.container [ class "py-4" ]
        [ Grid.row []
            [ Grid.col [ Col.md4 ]
                [ productCard "MacBook Air" "Apple" "https://images-na.ssl-images-amazon.com/images/I/81UdIMh89YL._SL1500_.jpg"
                ]
            , Grid.col [ Col.md4 ]
                [ productCard "Gamer Xtreme" "Cyberpower" "https://images-na.ssl-images-amazon.com/images/I/71DvG2FjM%2BL._SL1500_.jpg"
                ]
            , Grid.col [ Col.md4 ]
                [ productCard "Galaxy A70" "Samsung" "https://images-na.ssl-images-amazon.com/images/I/61Ygdf5VvoL._SL1500_.jpg"
                ]
            ]
        ]


productCard : String -> String -> String -> Html.Html Msg
productCard name brand imageUrl =
    Card.config [ Card.attrs [ class "mb-3" ] ]
        |> Card.imgTop [ src imageUrl, class "img-fluid" ] []
        |> Card.block
            [ Block.attrs [ class "d-flex justify-content-between align-items-end" ] ]
            [ Block.custom <|
                div []
                    [ h6 [ class "card-title mb-1" ] [ text brand ]
                    , h4 [ class "card-title mb-0" ] [ text name ]
                    ]
            , Block.custom <|
                Button.button
                    [ Button.secondary
                    , Button.attrs [ class "float-right stretched-link" ]
                    ]
                    [ text "Detail" ]
            ]
        |> Card.view


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
