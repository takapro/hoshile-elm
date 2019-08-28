module Main exposing (main)

import Bootstrap.Navbar as Navbar
import Browser
import Browser.Navigation as Nav
import Config
import Html exposing (Html, div)
import Navigation exposing (storeFooter, storeHeader, storeNav)
import Page.NotFound
import Page.ProductDetail
import Page.ProductList
import Route exposing (Route)
import Url exposing (Url)


type alias Model =
    { key : Nav.Key
    , navState : Navbar.State
    , page : Page
    }


type Page
    = NotFound
    | ProductList Page.ProductList.Model
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

        ( model, cmd ) =
            goTo (Route.parse url) (Model key navState NotFound)
    in
    ( model, Cmd.batch [ navCmd, cmd ] )


subscriptions : Model -> Sub Msg
subscriptions model =
    Navbar.subscriptions model.navState NavMsg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlChange url ->
            goTo (Route.parse url) model

        UrlRequest (Browser.Internal url) ->
            ( model, Nav.pushUrl model.key (Url.toString url) )

        UrlRequest (Browser.External href) ->
            ( model, Nav.load href )

        NavMsg state ->
            ( { model | navState = state }, Cmd.none )

        ProductListMsg pageMsg ->
            case model.page of
                ProductList page ->
                    updatePage model ProductList ProductListMsg <|
                        Page.ProductList.update pageMsg page

                _ ->
                    ( model, Cmd.none )

        ProductDetailMsg pageMsg ->
            case model.page of
                ProductDetail page ->
                    updatePage model ProductDetail ProductDetailMsg <|
                        Page.ProductDetail.update pageMsg page

                _ ->
                    ( model, Cmd.none )


goTo : Maybe Route -> Model -> ( Model, Cmd Msg )
goTo route model =
    case route of
        Nothing ->
            ( { model | page = NotFound }, Cmd.none )

        Just Route.Top ->
            updatePage model ProductList ProductListMsg <|
                Page.ProductList.init

        Just (Route.Product id) ->
            updatePage model ProductDetail ProductDetailMsg <|
                Page.ProductDetail.init id


updatePage : Model -> (page -> Page) -> (msg -> Msg) -> ( page, Cmd msg ) -> ( Model, Cmd Msg )
updatePage model pageConstructor msgConstructor =
    Tuple.mapBoth (\page -> { model | page = pageConstructor page }) (Cmd.map msgConstructor)


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


pageView : Page -> Html Msg
pageView page =
    case page of
        NotFound ->
            Page.NotFound.view

        ProductList model ->
            Html.map ProductListMsg (Page.ProductList.view model)

        ProductDetail model ->
            Html.map ProductDetailMsg (Page.ProductDetail.view model)
