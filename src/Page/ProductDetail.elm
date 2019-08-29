module Page.ProductDetail exposing (Model, Msg, init, update, view)

import Bootstrap.Button as Button
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Config
import Entity.Product as Product exposing (Product)
import Html exposing (Html, h4, h6, img, p, text)
import Html.Attributes exposing (class, src)
import Http
import Util.FetchState exposing (FetchState(..))


type alias Model =
    FetchState Product


type Msg
    = Receive (Result Http.Error Product)


init : Int -> ( Model, Cmd Msg )
init id =
    ( Loading
    , Http.get
        { url = Config.productApi ++ "/" ++ String.fromInt id
        , expect = Http.expectJson Receive Product.decoder
        }
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Receive (Ok result) ->
            ( Success result, Cmd.none )

        Receive (Err error) ->
            ( Failure (Debug.toString error), Cmd.none )


view : Model -> Html Msg
view model =
    Grid.container [ class "py-4" ]
        [ Grid.row []
            (case model of
                Loading ->
                    [ Grid.col [] [ text "Loading..." ] ]

                Success product ->
                    productView product

                Failure message ->
                    [ Grid.col [] [ text message ] ]
            )
        ]


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
