module Page.ProductDetail exposing (Model, Msg, init, title, update, view)

import Bootstrap.Button as Button exposing (onClick, primary)
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Config exposing (Config)
import Entity.CartEntry exposing (CartEntry)
import Entity.Product as Product exposing (Product)
import Html exposing (Html, h4, h6, img, p, text)
import Html.Attributes exposing (class, src)
import Session
import Util.Api as Api
import Util.Fetch as Fetch exposing (FetchState(..))
import View.CustomAlert as CustomAlert


type alias Model =
    FetchState Product


type Msg
    = Receive (FetchState Product)
    | AddToCart Int


init : Config -> Int -> ( Model, Cmd Msg )
init config id =
    ( Loading
    , Fetch.get Receive Product.decoder (Api.product config id)
    )


update : Msg -> Model -> (Msg -> msg) -> (Session.Msg -> Cmd msg) -> ( Model, Cmd msg )
update msg model _ sessionCmd =
    case msg of
        Receive fetchState ->
            ( fetchState, Cmd.none )

        AddToCart id ->
            ( model, sessionCmd (Session.MergeCart [ CartEntry id 1 ] (Just "/shoppingCart")) )


title : Model -> String -> String
title model defaultTitle =
    case model of
        Success product ->
            product.name

        _ ->
            defaultTitle


view : Model -> Html Msg
view model =
    Grid.container [ class "py-4" ]
        (CustomAlert.fetchState "Fetch" model <|
            \product -> [ Grid.row [] (productView product) ]
        )


productView : Product -> List (Grid.Column Msg)
productView product =
    [ Grid.col [ Col.md8 ]
        [ img [ src product.imageUrl, class "img-fluid" ] []
        ]
    , Grid.col [ Col.md4, Col.attrs [ class "mt-4" ] ]
        [ h6 [] [ text product.brand ]
        , h4 [] [ text product.name ]
        , p [] [ text ("Price: $" ++ String.fromFloat product.price) ]
        , Button.button
            [ primary, onClick (AddToCart product.id) ]
            [ text "Add to Cart" ]
        ]
    ]
