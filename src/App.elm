module Main exposing (main)

import Bootstrap.Navbar as Navbar
import Browser
import Html exposing (div)
import Navigation exposing (storeFooter, storeHeader, storeNav)
import Page.ProductList


type alias Model =
    { navState : Navbar.State
    , pageModel : PageModel
    }


type PageModel
    = ProductListModel Page.ProductList.Model


type Msg
    = NavMsg Navbar.State
    | ProductListMsg Page.ProductList.Msg


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

        ( pageModel, pageMsg ) =
            Page.ProductList.init
    in
    ( { navState = navState
      , pageModel = ProductListModel pageModel
      }
    , Cmd.batch [ navCmd, Cmd.map ProductListMsg pageMsg ]
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Navbar.subscriptions model.navState NavMsg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.pageModel ) of
        ( NavMsg state, _ ) ->
            ( { model | navState = state }, Cmd.none )

        ( ProductListMsg pageMsg, ProductListModel pageModel ) ->
            let
                ( newModel, cmd ) =
                    Page.ProductList.update pageMsg pageModel
            in
            ( { model | pageModel = ProductListModel newModel }, cmd )


view : Model -> Html.Html Msg
view model =
    div []
        [ storeHeader
        , storeNav model.navState NavMsg
        , pageView model.pageModel
        , storeFooter
        ]


pageView : PageModel -> Html.Html msg
pageView pageModel =
    case pageModel of
        ProductListModel model ->
            Page.ProductList.view model
