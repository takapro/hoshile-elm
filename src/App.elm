module Main exposing (main)

import Bootstrap.Navbar as Navbar
import Browser
import FetchState exposing (FetchMsg(..), FetchState(..), updateFetch)
import Html exposing (div)
import Navigation exposing (storeFooter, storeHeader, storeNav)
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
        , storeNav model.navState NavMsg
        , productList model.productList
        , storeFooter
        ]
