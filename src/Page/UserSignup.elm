module Page.UserSignup exposing (Model, Msg, init, update, view)

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
import Session
import Shared exposing (Shared)
import Util.Api as Api
import Util.Fetch as Fetch exposing (FetchState(..))
import Util.ListUtil as ListUtil
import Util.NavUtil exposing (href)
import View.CustomAlert as CustomAlert


type alias Model =
    { forPurchase : Bool
    , name : String
    , email : String
    , password1 : String
    , password2 : String
    , signupState : Maybe (FetchState User)
    }


type Msg
    = Name String
    | Email String
    | Password1 String
    | Password2 String
    | Signup
    | Receive (FetchState User)


init : Shared t -> Maybe String -> ( Model, Cmd Msg )
init shared forPurchase =
    ( Model (forPurchase == Just "true") "" "" "" "" Nothing, Cmd.none )


update : Msg -> Shared t -> Model -> (Msg -> msg) -> (Session.Msg -> Cmd msg) -> ( Model, Cmd msg )
update msg shared model wrapMsg sessionCmd =
    case msg of
        Name name ->
            ( { model | name = name }, Cmd.none )

        Email email ->
            ( { model | email = email }, Cmd.none )

        Password1 password1 ->
            ( { model | password1 = password1 }, Cmd.none )

        Password2 password2 ->
            ( { model | password2 = password2 }, Cmd.none )

        Signup ->
            ( { model | signupState = Just Loading }, Cmd.map wrapMsg (signupCmd shared model) )

        Receive (Success user) ->
            ( model, sessionCmd (Session.Login user (linkPath model "/" "/shoppingCart")) )

        Receive fetchState ->
            ( { model | signupState = Just fetchState }, Cmd.none )


linkPath : Model -> String -> String -> String
linkPath { forPurchase } path1 path2 =
    if forPurchase then
        path2

    else
        path1


cantSignup : Model -> Bool
cantSignup { name, email, password1, password2, signupState } =
    name == "" || email == "" || password1 == "" || password1 /= password2 || signupState == Just Loading


signupCmd : Shared t -> Model -> Cmd Msg
signupCmd shared { name, email, password1 } =
    Fetch.post Receive User.decoder (Api.user shared.config "signup") <|
        Encode.object
            [ ( "name", Encode.string name )
            , ( "email", Encode.string email )
            , ( "password", Encode.string password1 )
            ]


view : Shared t -> Model -> Html Msg
view shared model =
    Grid.container [ class "py-4" ]
        [ Grid.row [ Row.attrs [ class "justify-content-center" ] ]
            [ Grid.col [ Col.md6 ]
                (ListUtil.append3
                    [ h3 [ class "mb-3" ]
                        [ text "Please Sign up, or "
                        , a [ href shared.config.nav (linkPath model "/login" "/login?forPurchase=true") ] [ text "Log in" ]
                        ]
                    ]
                    (CustomAlert.errorIfFailure "Signup" model.signupState)
                    [ Form.form []
                        [ Form.group []
                            [ Form.label [] [ text "Name" ]
                            , Input.text [ value model.name, onInput Name, Input.attrs [ autofocus True ] ]
                            ]
                        , Form.group []
                            [ Form.label [] [ text "Email" ]
                            , Input.email [ value model.email, onInput Email ]
                            ]
                        , Form.group []
                            [ Form.label [] [ text "Password" ]
                            , Input.password [ value model.password1, onInput Password1 ]
                            ]
                        , Form.group []
                            [ Form.label [] [ text "Confirm Password" ]
                            , Input.password [ value model.password2, onInput Password2 ]
                            ]
                        , Button.button [ primary, onClick Signup, disabled (cantSignup model) ]
                            (CustomAlert.spinnerLabel model.signupState "Sign up")
                        ]
                    ]
                )
            ]
        ]
