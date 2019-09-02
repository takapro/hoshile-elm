module App exposing (main)

import Bootstrap.Navbar as Navbar
import Browser
import Browser.Navigation as Nav
import Config exposing (Flags)
import Html exposing (Html, div)
import Page.About
import Page.NotFound
import Page.OrderDetail
import Page.OrderList
import Page.ProductDetail
import Page.ProductList
import Page.ShoppingCart
import Page.UserLogin
import Page.UserProfile
import Page.UserSignup
import Route exposing (Route)
import Session
import Shared exposing (Shared)
import Task
import Url exposing (Url)
import Util.NavUtil as NavUtil
import View.Footer as Footer
import View.Header as Header
import View.Navigation as Navigation


type alias Model =
    Shared { page : Page }


type Page
    = NotFound
    | ProductList Page.ProductList.Model
    | ProductDetail Page.ProductDetail.Model
    | About
    | UserLogin Page.UserLogin.Model
    | UserSignup Page.UserSignup.Model
    | UserProfile Page.UserProfile.Model
    | ShoppingCart Page.ShoppingCart.Model
    | OrderList Page.OrderList.Model
    | OrderDetail Page.OrderDetail.Model


type Msg
    = UrlChange Url
    | UrlRequest Browser.UrlRequest
    | SessionMsg Session.Msg
    | NavMsg Navbar.State
    | ProductListMsg Page.ProductList.Msg
    | ProductDetailMsg Page.ProductDetail.Msg
    | UserLoginMsg Page.UserLogin.Msg
    | UserSignupMsg Page.UserSignup.Msg
    | UserProfileMsg Page.UserProfile.Msg
    | ShoppingCartMsg Page.ShoppingCart.Msg
    | OrderListMsg Page.OrderList.Msg
    | OrderDetailMsg Page.OrderDetail.Msg


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , onUrlChange = UrlChange
        , onUrlRequest = UrlRequest
        , subscriptions = subscriptions
        , update = update
        , view = view
        }


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        config =
            Config.init flags key

        ( navState, navCmd ) =
            Navbar.initialState NavMsg

        ( model, cmd ) =
            goTo (NavUtil.parse config.nav url)
                { config = config
                , session = Session.init
                , navState = navState
                , page = NotFound
                }
    in
    ( model, Cmd.batch [ navCmd, cmd ] )


subscriptions : Model -> Sub Msg
subscriptions model =
    Navbar.subscriptions model.navState NavMsg


sessionCmd : Session.Msg -> Cmd Msg
sessionCmd msg =
    Task.succeed (SessionMsg msg)
        |> Task.perform identity


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlChange url ->
            goTo (NavUtil.parse model.config.nav url) model

        UrlRequest (Browser.Internal url) ->
            ( model, Nav.pushUrl model.config.nav.key (Url.toString url) )

        UrlRequest (Browser.External href) ->
            ( model, Nav.load href )

        SessionMsg sessionMsg ->
            Session.update sessionMsg model.config model.session SessionMsg sessionCmd
                |> Tuple.mapFirst (\session -> { model | session = session })

        NavMsg state ->
            ( { model | navState = state }, Cmd.none )

        ProductListMsg pageMsg ->
            case model.page of
                ProductList page ->
                    Page.ProductList.update pageMsg model page
                        |> mapPage model ProductList ProductListMsg

                _ ->
                    ( model, Cmd.none )

        ProductDetailMsg pageMsg ->
            case model.page of
                ProductDetail page ->
                    Page.ProductDetail.update pageMsg model page ProductDetailMsg sessionCmd
                        |> mapPage model ProductDetail identity

                _ ->
                    ( model, Cmd.none )

        UserLoginMsg pageMsg ->
            case model.page of
                UserLogin page ->
                    Page.UserLogin.update pageMsg model page UserLoginMsg sessionCmd
                        |> mapPage model UserLogin identity

                _ ->
                    ( model, Cmd.none )

        UserSignupMsg pageMsg ->
            case model.page of
                UserSignup page ->
                    Page.UserSignup.update pageMsg model page UserSignupMsg sessionCmd
                        |> mapPage model UserSignup identity

                _ ->
                    ( model, Cmd.none )

        UserProfileMsg pageMsg ->
            case model.page of
                UserProfile page ->
                    Page.UserProfile.update pageMsg model page UserProfileMsg sessionCmd
                        |> mapPage model UserProfile identity

                _ ->
                    ( model, Cmd.none )

        ShoppingCartMsg pageMsg ->
            case model.page of
                ShoppingCart page ->
                    Page.ShoppingCart.update pageMsg model page ShoppingCartMsg sessionCmd
                        |> mapPage model ShoppingCart identity

                _ ->
                    ( model, Cmd.none )

        OrderListMsg pageMsg ->
            case model.page of
                OrderList page ->
                    Page.OrderList.update pageMsg model page
                        |> mapPage model OrderList OrderListMsg

                _ ->
                    ( model, Cmd.none )

        OrderDetailMsg pageMsg ->
            case model.page of
                OrderDetail page ->
                    Page.OrderDetail.update pageMsg model page
                        |> mapPage model OrderDetail OrderDetailMsg

                _ ->
                    ( model, Cmd.none )


goTo : Maybe Route -> Model -> ( Model, Cmd Msg )
goTo route model =
    case route of
        Nothing ->
            ( { model | page = NotFound }, Cmd.none )

        Just Route.Top ->
            Page.ProductList.init model
                |> mapPage model ProductList ProductListMsg

        Just (Route.Product id) ->
            Page.ProductDetail.init model id
                |> mapPage model ProductDetail ProductDetailMsg

        Just Route.About ->
            ( { model | page = About }, Cmd.none )

        Just (Route.Login forPurchase) ->
            Page.UserLogin.init model forPurchase
                |> mapPage model UserLogin UserLoginMsg

        Just Route.Logout ->
            ( model, sessionCmd (Session.Logout "/") )

        Just (Route.Signup forPurchase) ->
            Page.UserSignup.init model forPurchase
                |> mapPage model UserSignup UserSignupMsg

        Just Route.Profile ->
            Page.UserProfile.init model
                |> mapPage model UserProfile UserProfileMsg

        Just Route.ShoppingCart ->
            Page.ShoppingCart.init model
                |> mapPage model ShoppingCart ShoppingCartMsg

        Just Route.OrderList ->
            Page.OrderList.init model
                |> mapPage model OrderList OrderListMsg

        Just (Route.OrderDetail id) ->
            Page.OrderDetail.init model id
                |> mapPage model OrderDetail OrderDetailMsg


mapPage : Model -> (page -> Page) -> (msg -> Msg) -> ( page, Cmd msg ) -> ( Model, Cmd Msg )
mapPage model pageConstructor msgConstructor =
    Tuple.mapBoth (\pageModel -> { model | page = pageConstructor pageModel }) (Cmd.map msgConstructor)


view : Model -> Browser.Document Msg
view model =
    let
        ( title, content ) =
            pageView model
    in
    { title =
        if title == "" then
            model.config.title

        else
            model.config.title ++ " - " ++ title
    , body =
        [ div []
            [ Header.view model
            , Navigation.view model NavMsg
            , content
            , Footer.view
            ]
        ]
    }


pageView : Model -> ( String, Html Msg )
pageView model =
    case model.page of
        NotFound ->
            ( "Not Found", Page.NotFound.view )

        ProductList page ->
            ( "", Html.map ProductListMsg (Page.ProductList.view model page) )

        ProductDetail page ->
            ( Page.ProductDetail.title page "Product Detail"
            , Html.map ProductDetailMsg (Page.ProductDetail.view model page)
            )

        About ->
            ( "About", Page.About.view )

        UserLogin page ->
            ( "Log in", Html.map UserLoginMsg (Page.UserLogin.view model page) )

        UserSignup page ->
            ( "Sign up", Html.map UserSignupMsg (Page.UserSignup.view model page) )

        UserProfile page ->
            ( "Profile", Html.map UserProfileMsg (Page.UserProfile.view model page) )

        ShoppingCart page ->
            ( "Shopping Cart", Html.map ShoppingCartMsg (Page.ShoppingCart.view model page) )

        OrderList page ->
            ( "Order List", Html.map OrderListMsg (Page.OrderList.view model page) )

        OrderDetail page ->
            ( "Order Detail", Html.map OrderDetailMsg (Page.OrderDetail.view model page) )
