module Page.ProductDetail exposing (Model, Msg, init, update, view)

import Bootstrap.Button as Button
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Config
import Entity.Product as Product exposing (Product)
import Html exposing (Html, h4, h6, img, p, text)
import Html.Attributes exposing (class, src)
import Util.Fetch as Fetch exposing (FetchState(..))
import View.CustomAlert as CustomAlert


type alias Model =
    FetchState Product


type Msg
    = Receive (FetchState Product)


init : Int -> ( Model, Cmd Msg )
init id =
    ( Loading
    , Fetch.get Receive Product.decoder <|
        (Config.productApi ++ "/" ++ String.fromInt id)
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg _ =
    case msg of
        Receive fetchState ->
            ( fetchState, Cmd.none )


view : Model -> Html Msg
view model =
    Grid.container [ class "py-4" ]
        (CustomAlert.fetchState "Fetch" model <|
            \product -> [ Grid.row [] (productView product) ]
        )


productView : Product -> List (Grid.Column msg)
productView product =
    [ Grid.col [ Col.md8 ]
        [ img [ src product.imageUrl, class "img-fluid" ] []
        ]
    , Grid.col [ Col.md4, Col.attrs [ class "mt-4" ] ]
        [ h6 [] [ text product.brand ]
        , h4 [] [ text product.name ]
        , p [] [ text ("Price: $" ++ String.fromFloat product.price) ]
        , Button.button
            [ Button.primary ]
            [ text "Add to Cart" ]
        ]
    ]
