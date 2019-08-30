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
    Task.perform identity <| Task.succeed (SessionMsg msg)


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
            Tuple.mapFirst (\session -> { model | session = session }) <|
                Session.update sessionMsg model.key model.session

        NavMsg state ->
            ( { model | navState = state }, Cmd.none )

        ProductListMsg pageMsg ->
            case model.page of
                ProductList page ->
                    updatePage ProductList ProductListMsg model <|
                        Page.ProductList.update pageMsg page

                _ ->
                    ( model, Cmd.none )

        ProductDetailMsg pageMsg ->
            case model.page of
                ProductDetail page ->
                    updatePage ProductDetail ProductDetailMsg model <|
                        Page.ProductDetail.update pageMsg page

                _ ->
                    ( model, Cmd.none )

        UserLoginMsg pageMsg ->
            case model.page of
                UserLogin page ->
                    updatePage UserLogin identity model <|
                        Page.UserLogin.update pageMsg page UserLoginMsg sessionCmd

                _ ->
                    ( model, Cmd.none )

        UserSignupMsg pageMsg ->
            case model.page of
                UserSignup page ->
                    updatePage UserSignup identity model <|
                        Page.UserSignup.update pageMsg page UserSignupMsg sessionCmd

                _ ->
                    ( model, Cmd.none )

        UserProfileMsg pageMsg ->
            case model.page of
                UserProfile page ->
                    updatePage UserProfile identity model <|
                        Page.UserProfile.update pageMsg page UserProfileMsg sessionCmd

                _ ->
                    ( model, Cmd.none )

        ShoppingCartMsg pageMsg ->
            case model.page of
                ShoppingCart page ->
                    updatePage ShoppingCart ShoppingCartMsg model <|
                        Page.ShoppingCart.update pageMsg page

                _ ->
                    ( model, Cmd.none )


goTo : Maybe Route -> Model -> ( Model, Cmd Msg )
goTo route model =
    case route of
        Nothing ->
            ( { model | page = NotFound }, Cmd.none )

        Just Route.Top ->
            updatePage ProductList ProductListMsg model <|
                Page.ProductList.init

        Just (Route.Product id) ->
            updatePage ProductDetail ProductDetailMsg model <|
                Page.ProductDetail.init id

        Just Route.About ->
            ( { model | page = About }, Cmd.none )

        Just Route.Login ->
            updatePage UserLogin UserLoginMsg model <|
                Page.UserLogin.init

        Just Route.Logout ->
            ( model, sessionCmd (Session.Logout "/") )

        Just Route.Signup ->
            updatePage UserSignup UserSignupMsg model <|
                Page.UserSignup.init

        Just Route.Profile ->
            updatePage UserProfile UserProfileMsg model <|
                Page.UserProfile.init model.session.user

        Just Route.ShoppingCart ->
            updatePage ShoppingCart ShoppingCartMsg model <|
                Page.ShoppingCart.init model.session.shoppingCart


updatePage : (page -> Page) -> (msg -> Msg) -> Model -> ( page, Cmd msg ) -> ( Model, Cmd Msg )
updatePage pageConstructor msgConstructor model =
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
