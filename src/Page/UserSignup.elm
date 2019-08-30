module Page.UserSignup exposing (Model, Msg, init, update, view)

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
import Http
import Json.Encode as Encode
import Session
import Util.FetchState exposing (FetchState(..))
import Util.ListUtil as ListUtil


type alias Model =
    { name : String
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
    | Receive (Result Http.Error User)


init : ( Model, Cmd Msg )
init =
    ( Model "" "" "" "" Nothing, Cmd.none )


update : Msg -> Model -> (Msg -> msg) -> (Session.Msg -> Cmd msg) -> ( Model, Cmd msg )
update msg model wrapMsg sessionCmd =
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
            ( { model | signupState = Just Loading }, Cmd.map wrapMsg (signupCmd model) )

        Receive (Ok user) ->
            ( model, sessionCmd (Session.Login user "/") )

        Receive (Err error) ->
            ( { model | signupState = Just (Failure (Debug.toString error)) }, Cmd.none )


cantSignup : Model -> Bool
cantSignup model =
    (model.name == "" || model.email == "" || model.password1 == "")
        || (model.password1 /= model.password2 || model.signupState == Just Loading)


signupCmd : Model -> Cmd Msg
signupCmd { name, email, password1 } =
    Http.post
        { url = Config.userApi ++ "/signup"
        , body =
            Http.jsonBody
                (Encode.object
                    [ ( "name", Encode.string name )
                    , ( "email", Encode.string email )
                    , ( "password", Encode.string password1 )
                    ]
                )
        , expect = Http.expectJson Receive User.decoder
        }


view : Model -> Html Msg
view model =
    Grid.container [ class "py-4" ]
        [ Grid.row [ Row.attrs [ class "justify-content-center" ] ]
            [ Grid.col [ Col.md6 ]
                (ListUtil.append3
                    [ h3 [ class "mb-3" ] [ text "Please Sign up" ]
                    ]
                    (case model.signupState of
                        Just (Failure error) ->
                            [ Alert.simpleDanger []
                                [ text ("Signup failed: " ++ error) ]
                            ]

                        _ ->
                            []
                    )
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
                            (if model.signupState == Just Loading then
                                [ Spinner.spinner [ Spinner.small, Spinner.attrs [ class "mr-2" ] ] []
                                , text "Sign up"
                                ]

                             else
                                [ text "Sign up" ]
                            )
                        ]
                    ]
                )
            ]
        ]
