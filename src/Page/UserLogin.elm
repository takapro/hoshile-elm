module Page.UserLogin exposing (Model, Msg, init, update, view)

import Bootstrap.Button as Button
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Config
import Entity.User as User exposing (User)
import Html exposing (Html, h3, text)
import Html.Attributes exposing (class)
import Http
import Json.Encode as Encode
import Util.FetchState exposing (FetchState(..))


type alias Model =
    { email : String
    , password : String
    , fetchState : Maybe (FetchState User)
    }


type Msg
    = Email String
    | Password String
    | Login
    | Receive (Result Http.Error User)


init : ( Model, Cmd Msg )
init =
    ( Model "" "" Nothing, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Email email ->
            ( { model | email = email }, Cmd.none )

        Password password ->
            ( { model | password = password }, Cmd.none )

        Login ->
            ( { model | fetchState = Just Loading }, loginCmd model )

        Receive (Ok result) ->
            ( { model | fetchState = Just (Success result) }, Cmd.none )

        Receive (Err error) ->
            ( { model | fetchState = Just (Failure (Debug.toString error)) }, Cmd.none )


loginCmd : Model -> Cmd Msg
loginCmd { email, password } =
    Http.post
        { url = Config.userApi ++ "/login"
        , body =
            Http.jsonBody
                (Encode.object
                    [ ( "email", Encode.string email )
                    , ( "password", Encode.string password )
                    ]
                )
        , expect = Http.expectJson Receive User.decoder
        }


view : Model -> Html Msg
view model =
    Grid.container [ class "py-4" ]
        [ Grid.row [ Row.attrs [ class "justify-content-center" ] ]
            [ Grid.col [ Col.md6 ]
                ([ h3 [ class "mb-3" ] [ text "Please Log in" ]
                 ]
                    ++ (case model.fetchState of
                            Nothing ->
                                []

                            Just Loading ->
                                [ text "Loading..." ]

                            Just (Success user) ->
                                [ text ("Success: " ++ user.name) ]

                            Just (Failure error) ->
                                [ text ("Failure: " ++ error) ]
                       )
                    ++ [ Form.form []
                            [ Form.group []
                                [ Form.label [] [ text "Email" ]
                                , Input.email
                                    [ Input.value model.email
                                    , Input.onInput Email
                                    ]
                                ]
                            , Form.group []
                                [ Form.label [] [ text "Password" ]
                                , Input.password
                                    [ Input.value model.password
                                    , Input.onInput Password
                                    ]
                                ]
                            , Button.button
                                [ Button.primary
                                , Button.onClick Login
                                ]
                                [ text "Log in" ]
                            ]
                       ]
                )
            ]
        ]
