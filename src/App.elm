module Main exposing (main)

import Bootstrap.Navbar as Navbar
import Browser
import Browser.Navigation as Nav
import Config
import Html exposing (Html, div)
import Navigation exposing (storeFooter, storeHeader, storeNav)
import Page.ProductDetail
import Page.ProductList
import Url exposing (Url)


type alias Model =
    { url : Url
    , key : Nav.Key
    , navState : Navbar.State
    , page : Page
    }


type Page
    = ProductList Page.ProductList.Model
    | ProductDetail Page.ProductDetail.Model


type Msg
    = UrlChange Url
    | UrlRequest Browser.UrlRequest
    | NavMsg Navbar.State
    | ProductListMsg Page.ProductList.Msg
    | ProductDetailMsg Page.ProductDetail.Msg


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , onUrlChange = UrlChange
        , onUrlRequest = UrlRequest
        , subscriptions = subscriptions
        , update = update
        , view = view
        }


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init () url key =
    let
        ( navState, navCmd ) =
            Navbar.initialState NavMsg

        ( page, msg ) =
            Page.ProductList.init
    in
    ( { url = url
      , key = key
      , navState = navState
      , page = ProductList page
      }
    , Cmd.batch [ navCmd, Cmd.map ProductListMsg msg ]
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Navbar.subscriptions model.navState NavMsg


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        UrlChange url ->
            ( { model | url = url }, Cmd.none )

        UrlRequest (Browser.Internal url) ->
            ( model, Nav.pushUrl model.key (Url.toString url) )

        UrlRequest (Browser.External href) ->
            ( model, Nav.load href )

        NavMsg state ->
            ( { model | navState = state }, Cmd.none )

        ProductListMsg pageMsg ->
            case model.page of
                ProductList page ->
                    updatePage model
                        ProductList
                        (Page.ProductList.update pageMsg page)

                _ ->
                    ( model, Cmd.none )

        ProductDetailMsg pageMsg ->
            case model.page of
                ProductDetail page ->
                    updatePage model
                        ProductDetail
                        (Page.ProductDetail.update pageMsg page)

                _ ->
                    ( model, Cmd.none )


updatePage : Model -> (page -> Page) -> ( page, cmd ) -> ( Model, cmd )
updatePage model f ( page, cmd ) =
    ( { model | page = f page }, cmd )


view : Model -> Browser.Document Msg
view model =
    { title = Config.title
    , body =
        [ div []
            [ storeHeader
            , storeNav model.navState NavMsg
            , pageView model.page
            , storeFooter
            ]
        ]
    }


pageView : Page -> Html msg
pageView page =
    case page of
        ProductList model ->
            Page.ProductList.view model

        ProductDetail model ->
            Page.ProductDetail.view model
