module Page.UserLogin exposing (Model, Msg, init, update, view)

import Bootstrap.Alert as Alert
import Bootstrap.Button as Button exposing (disabled, onClick, primary)
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input exposing (onInput, value)
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Spinner as Spinner
import Config
import Entity.User as User exposing (User)
import Html exposing (Html, h3, text)
import Html.Attributes exposing (autofocus, class)
import Json.Encode as Encode
import Session
import Util.Fetch as Fetch exposing (FetchState(..))
import Util.ListUtil as ListUtil


type alias Model =
    { email : String
    , password : String
    , loginState : Maybe (FetchState User)
    }


type Msg
    = Email String
    | Password String
    | Login
    | Receive (FetchState User)


init : ( Model, Cmd Msg )
init =
    ( Model "" "" Nothing, Cmd.none )


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
            ( model, sessionCmd (Session.Login user "/") )

        Receive fetchState ->
            ( { model | loginState = Just fetchState }, Cmd.none )


cantLogin : Model -> Bool
cantLogin model =
    model.email == "" || model.password == "" || model.loginState == Just Loading


loginCmd : Model -> Cmd Msg
loginCmd { email, password } =
    Fetch.post Receive User.decoder (Config.userApi ++ "/login") <|
        Encode.object
            [ ( "email", Encode.string email )
            , ( "password", Encode.string password )
            ]


view : Model -> Html Msg
view model =
    Grid.container [ class "py-4" ]
        [ Grid.row [ Row.attrs [ class "justify-content-center" ] ]
            [ Grid.col [ Col.md6 ]
                (ListUtil.append3
                    [ h3 [ class "mb-3" ] [ text "Please Log in" ]
                    ]
                    (case model.loginState of
                        Just (Failure error) ->
                            [ Alert.simpleDanger []
                                [ text ("Login failed: " ++ error) ]
                            ]

                        _ ->
                            []
                    )
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
                            (if model.loginState == Just Loading then
                                [ Spinner.spinner [ Spinner.small, Spinner.attrs [ class "mr-2" ] ] []
                                , text "Log in"
                                ]

                             else
                                [ text "Log in" ]
                            )
                        ]
                    ]
                )
            ]
        ]
