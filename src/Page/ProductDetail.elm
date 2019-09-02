module Page.ProductDetail exposing (Model, Msg, init, title, update, view)

import Bootstrap.Button as Button exposing (onClick, primary)
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Entity.CartEntry exposing (CartEntry)
import Entity.Product as Product exposing (Product)
import Html exposing (Html, h4, h6, img, p, text)
import Html.Attributes exposing (class, src)
import Return exposing (Return, return, withCmd, withSessionMsg)
import Session
import Shared exposing (Shared)
import Util.Api as Api
import Util.Fetch as Fetch exposing (FetchState(..))
import View.CustomAlert as CustomAlert


type alias Model =
    FetchState Product


type Msg
    = Receive (FetchState Product)
    | AddToCart Int


init : Shared t -> Int -> Return Model Msg msg
init { config } id =
    return Loading
        |> withCmd (Fetch.get Receive Product.decoder (Api.product config id))


update : Msg -> Shared t -> Model -> Return Model Msg Session.Msg
update msg _ model =
    case msg of
        Receive fetchState ->
            return fetchState

        AddToCart id ->
            return model
                |> withSessionMsg (Session.MergeCart [ CartEntry id 1 ] (Just "/shoppingCart"))


title : Model -> String -> String
title model defaultTitle =
    case model of
        Success product ->
            product.name

        _ ->
            defaultTitle


view : Shared t -> Model -> Html Msg
view _ model =
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
