module App exposing (main)

import Bootstrap.Navbar as Navbar
import Browser
import Browser.Navigation as Nav
import Config
import Html exposing (Html, div)
import Page.About
import Page.NotFound
import Page.ProductDetail
import Page.ProductList
import Page.ShoppingCart
import Page.UserLogin
import Page.UserProfile
import Page.UserSignup
import Route exposing (Route)
import Session
import Task
import Url exposing (Url)
import View.Footer as Footer
import View.Header as Header
import View.Navigation as Navigation


type alias Model =
    { key : Nav.Key
    , session : Session.Model
    , navState : Navbar.State
    , page : Page
    }


type Page
    = NotFound
    | ProductList Page.ProductList.Model
    | ProductDetail Page.ProductDetail.Model
    | About
    | UserLogin Page.UserLogin.Model
    | UserSignup Page.UserSignup.Model
    | UserProfile Page.UserProfile.Model
    | ShoppingCart Page.ShoppingCart.Model


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
            goTo (Route.parse url) (Model key Session.init navState NotFound)
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
            goTo (Route.parse url) model

        UrlRequest (Browser.Internal url) ->
            ( model, Nav.pushUrl model.key (Url.toString url) )

        UrlRequest (Browser.External href) ->
            ( model, Nav.load href )

        SessionMsg sessionMsg ->
            Session.update sessionMsg model.key model.session SessionMsg sessionCmd
                |> Tuple.mapFirst (\session -> { model | session = session })

        NavMsg state ->
            ( { model | navState = state }, Cmd.none )

        ProductListMsg pageMsg ->
            case model.page of
                ProductList page ->
                    Page.ProductList.update pageMsg page
                        |> mapPage model ProductList ProductListMsg

                _ ->
                    ( model, Cmd.none )

        ProductDetailMsg pageMsg ->
            case model.page of
                ProductDetail page ->
                    Page.ProductDetail.update pageMsg page ProductDetailMsg sessionCmd
                        |> mapPage model ProductDetail identity

                _ ->
                    ( model, Cmd.none )

        UserLoginMsg pageMsg ->
            case model.page of
                UserLogin page ->
                    Page.UserLogin.update pageMsg page UserLoginMsg sessionCmd
                        |> mapPage model UserLogin identity

                _ ->
                    ( model, Cmd.none )

        UserSignupMsg pageMsg ->
            case model.page of
                UserSignup page ->
                    Page.UserSignup.update pageMsg page UserSignupMsg sessionCmd
                        |> mapPage model UserSignup identity

                _ ->
                    ( model, Cmd.none )

        UserProfileMsg pageMsg ->
            case model.page of
                UserProfile page ->
                    Page.UserProfile.update pageMsg page UserProfileMsg sessionCmd
                        |> mapPage model UserProfile identity

                _ ->
                    ( model, Cmd.none )

        ShoppingCartMsg pageMsg ->
            case model.page of
                ShoppingCart page ->
                    Page.ShoppingCart.update model.key pageMsg page ShoppingCartMsg sessionCmd
                        |> mapPage model ShoppingCart identity

                _ ->
                    ( model, Cmd.none )


goTo : Maybe Route -> Model -> ( Model, Cmd Msg )
goTo route model =
    case route of
        Nothing ->
            ( { model | page = NotFound }, Cmd.none )

        Just Route.Top ->
            Page.ProductList.init
                |> mapPage model ProductList ProductListMsg

        Just (Route.Product id) ->
            Page.ProductDetail.init id
                |> mapPage model ProductDetail ProductDetailMsg

        Just Route.About ->
            ( { model | page = About }, Cmd.none )

        Just Route.Login ->
            Page.UserLogin.init
                |> mapPage model UserLogin UserLoginMsg

        Just Route.Logout ->
            ( model, sessionCmd (Session.Logout "/") )

        Just Route.Signup ->
            Page.UserSignup.init
                |> mapPage model UserSignup UserSignupMsg

        Just Route.Profile ->
            Page.UserProfile.init model.session.user
                |> mapPage model UserProfile UserProfileMsg

        Just Route.ShoppingCart ->
            Page.ShoppingCart.init model.session
                |> mapPage model ShoppingCart ShoppingCartMsg


mapPage : Model -> (page -> Page) -> (msg -> Msg) -> ( page, Cmd msg ) -> ( Model, Cmd Msg )
mapPage model pageConstructor msgConstructor =
    Tuple.mapBoth
        (\page -> { model | page = pageConstructor page })
        (Cmd.map msgConstructor)


view : Model -> Browser.Document Msg
view model =
    { title = Config.title
    , body =
        [ div []
            [ Header.view
            , Navigation.view model.session model.navState NavMsg
            , pageView model.page
            , Footer.view
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

        About ->
            Page.About.view

        UserLogin model ->
            Html.map UserLoginMsg (Page.UserLogin.view model)

        UserSignup model ->
            Html.map UserSignupMsg (Page.UserSignup.view model)

        UserProfile model ->
            Html.map UserProfileMsg (Page.UserProfile.view model)

        ShoppingCart model ->
            Html.map ShoppingCartMsg (Page.ShoppingCart.view model)
