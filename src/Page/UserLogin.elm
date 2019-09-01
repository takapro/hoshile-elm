module Page.UserLogin exposing (Model, Msg, init, update, view)

import Bootstrap.Button as Button exposing (disabled, onClick, primary)
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input exposing (onInput, value)
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Config
import Entity.User as User exposing (User)
import Html exposing (Html, a, h3, text)
import Html.Attributes exposing (autofocus, class)
import Json.Encode as Encode
import Session
import Util.Fetch as Fetch exposing (FetchState(..))
import Util.ListUtil as ListUtil
import Util.NavUtil as NavUtil
import View.CustomAlert as CustomAlert


type alias Model =
    { forPurchase : Bool
    , email : String
    , password : String
    , loginState : Maybe (FetchState User)
    }


type Msg
    = Email String
    | Password String
    | Login
    | Receive (FetchState User)


init : Maybe String -> ( Model, Cmd Msg )
init forPurchase =
    ( Model (forPurchase == Just "true") "" "" Nothing, Cmd.none )


update : Msg -> Model -> (Msg -> msg) -> (Session.Msg -> Cmd msg) -> ( Model, Cmd msg )
update msg model wrapMsg sessionCmd =
    case msg of
        Email email ->
            ( { model | email = email }, Cmd.none )

        Password password ->
            ( { model | password = password }, Cmd.none )

        Login ->
            ( { model | loginState = Just Loading }, Cmd.map wrapMsg (loginCmd model) )

        Receive (Success user) ->
            ( model, sessionCmd (Session.Login user (linkPath model "/" "/shoppingCart")) )

        Receive fetchState ->
            ( { model | loginState = Just fetchState }, Cmd.none )


linkPath : Model -> String -> String -> String
linkPath { forPurchase } path1 path2 =
    if forPurchase then
        path2

    else
        path1


cantLogin : Model -> Bool
cantLogin { email, password, loginState } =
    email == "" || password == "" || loginState == Just Loading


loginCmd : Model -> Cmd Msg
loginCmd { email, password } =
    Fetch.post Receive User.decoder (Config.userApi ++ "/login") <|
        Encode.object
            [ ( "email", Encode.string email )
            , ( "password", Encode.string password )
            ]


view : NavUtil.Model -> Model -> Html Msg
view nav model =
    Grid.container [ class "py-4" ]
        [ Grid.row [ Row.attrs [ class "justify-content-center" ] ]
            [ Grid.col [ Col.md6 ]
                (ListUtil.append3
                    [ h3 [ class "mb-3" ]
                        [ text "Please Log in, or "
                        , a [ NavUtil.href nav (linkPath model "/signup" "/signup?forPurchase=true") ] [ text "Sign up" ]
                        ]
                    ]
                    (CustomAlert.errorIfFailure "Login" model.loginState)
                    [ Form.form []
                        [ Form.group []
                            [ Form.label [] [ text "Email" ]
                            , Input.email [ value model.email, onInput Email, Input.attrs [ autofocus True ] ]
                            ]
                        , Form.group []
                            [ Form.label [] [ text "Password" ]
                            , Input.password [ value model.password, onInput Password ]
                            ]
                        , Button.button [ primary, onClick Login, disabled (cantLogin model) ]
                            (CustomAlert.spinnerLabel model.loginState "Log in")
                        ]
                    ]
                )
            ]
        ]
