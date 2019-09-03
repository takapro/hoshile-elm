module Page.UserLogin exposing (Model, Msg, init, update, view)

import Bootstrap.Button as Button exposing (disabled, onClick, primary)
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input exposing (onInput, value)
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Entity.User as User exposing (User)
import Html exposing (Html, a, h3, text)
import Html.Attributes exposing (autofocus, class)
import Json.Encode as Encode
import Return exposing (Return, return, withCmd, withSessionMsg)
import Session
import Shared exposing (Shared)
import Util.Api as Api
import Util.Fetch as Fetch exposing (FetchState(..))
import Util.ListUtil as ListUtil
import Util.NavUtil exposing (href)
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


init : Shared t -> Maybe String -> Return Model Msg msg
init _ forPurchase =
    return (Model (forPurchase == Just "true") "" "" Nothing)


update : Msg -> Shared t -> Model -> Return Model Msg Session.Msg
update msg shared model =
    case msg of
        Email email ->
            return { model | email = email }

        Password password ->
            return { model | password = password }

        Login ->
            return { model | loginState = Just Loading }
                |> withCmd (loginCmd shared model)

        Receive (Success user) ->
            return model
                |> withSessionMsg (Session.Login user (linkPath model "/" "/shoppingCart"))

        Receive fetchState ->
            return { model | loginState = Just fetchState }


linkPath : Model -> String -> String -> String
linkPath { forPurchase } path1 path2 =
    if forPurchase then
        path2

    else
        path1


cantLogin : Model -> Bool
cantLogin { email, password, loginState } =
    email == "" || password == "" || loginState == Just Loading


loginCmd : Shared t -> Model -> Cmd Msg
loginCmd { config } { email, password } =
    Fetch.post Receive User.decoder (Api.user config "login") <|
        Encode.object
            [ ( "email", Encode.string email )
            , ( "password", Encode.string password )
            ]


view : Shared t -> Model -> Html Msg
view { config } model =
    Grid.container [ class "py-4" ]
        [ Grid.row [ Row.attrs [ class "justify-content-center" ] ]
            [ Grid.col [ Col.md6 ]
                (ListUtil.append3
                    [ h3 [ class "mb-3" ]
                        [ text "Please Log in, or "
                        , a [ href config (linkPath model "/signup" "/signup?forPurchase=true") ] [ text "Sign up" ]
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
