module Page.UserProfile exposing (Model, Msg, init, update, view)

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
import Html exposing (Html, h3, hr, text)
import Html.Attributes exposing (class)
import Http
import Json.Encode as Encode
import Session
import Util.FetchState exposing (FetchState(..))
import Util.ListUtil as ListUtil


type alias Model =
    { user : Maybe User
    , name : String
    , email : String
    , curPassword : String
    , password1 : String
    , password2 : String
    , profileState : Maybe (FetchState User)
    , passwordState : Maybe (FetchState User)
    }


type Msg
    = Name String
    | Email String
    | CurPassword String
    | Password1 String
    | Password2 String
    | UpdateProfile
    | ReceiveProfile (Result Http.Error User)
    | UpdatePassword
    | ReceivePassword (Result Http.Error User)


init : Maybe User -> ( Model, Cmd Msg )
init maybeUser =
    ( case maybeUser of
        Just user ->
            Model (Just user) user.name user.email "" "" "" Nothing Nothing

        Nothing ->
            Model Nothing "" "" "" "" "" Nothing Nothing
    , Cmd.none
    )


update : Msg -> Model -> (Msg -> msg) -> (Session.Msg -> Cmd msg) -> ( Model, Cmd msg )
update msg model wrapMsg sessionCmd =
    case msg of
        Name name ->
            ( { model | name = name }, Cmd.none )

        Email email ->
            ( { model | email = email }, Cmd.none )

        CurPassword curPassword ->
            ( { model | curPassword = curPassword }, Cmd.none )

        Password1 password1 ->
            ( { model | password1 = password1 }, Cmd.none )

        Password2 password2 ->
            ( { model | password2 = password2 }, Cmd.none )

        UpdateProfile ->
            ( { model | profileState = Just Loading }, Cmd.map wrapMsg (profileCmd model) )

        ReceiveProfile (Ok user) ->
            ( model, sessionCmd (Session.Update user) )

        ReceiveProfile (Err error) ->
            ( { model | profileState = Just (Failure (Debug.toString error)) }, Cmd.none )

        UpdatePassword ->
            ( { model | passwordState = Just Loading }, Cmd.map wrapMsg (passwordCmd model) )

        ReceivePassword (Ok user) ->
            ( model, sessionCmd (Session.Update user) )

        ReceivePassword (Err error) ->
            ( { model | passwordState = Just (Failure (Debug.toString error)) }, Cmd.none )


cantUpdateProfile : Model -> Bool
cantUpdateProfile model =
    model.name == "" || model.email == "" || model.profileState == Just Loading


cantUpdatePassword : Model -> Bool
cantUpdatePassword model =
    (model.curPassword == "" || model.password1 == "")
        || (model.password1 /= model.password2 || model.passwordState == Just Loading)


profileCmd : Model -> Cmd Msg
profileCmd { name, email } =
    Http.post
        { url = Config.userApi ++ "/profile"
        , body =
            Http.jsonBody
                (Encode.object
                    [ ( "name", Encode.string name )
                    , ( "email", Encode.string email )
                    ]
                )
        , expect = Http.expectJson ReceiveProfile User.decoder
        }


passwordCmd : Model -> Cmd Msg
passwordCmd { curPassword, password1 } =
    Http.post
        { url = Config.userApi ++ "/password"
        , body =
            Http.jsonBody
                (Encode.object
                    [ ( "curPassword", Encode.string curPassword )
                    , ( "newPassword", Encode.string password1 )
                    ]
                )
        , expect = Http.expectJson ReceivePassword User.decoder
        }


view : Model -> Html Msg
view model =
    Grid.container [ class "py-4" ]
        [ Grid.row [ Row.attrs [ class "justify-content-center" ] ]
            (if model.user == Nothing then
                [ Grid.col []
                    [ Alert.simpleDanger []
                        [ text "Not logged in." ]
                    ]
                ]

             else
                [ Grid.col [ Col.md6 ]
                    (ListUtil.append3
                        (profileView model)
                        [ hr [ class "my-4" ] [] ]
                        (passwordView model)
                    )
                ]
            )
        ]


profileView : Model -> List (Html Msg)
profileView model =
    ListUtil.append3
        [ h3 [ class "mb-3" ] [ text "Profile" ]
        ]
        (case model.profileState of
            Just (Failure error) ->
                [ Alert.simpleDanger []
                    [ text ("Profile update failed: " ++ error) ]
                ]

            _ ->
                []
        )
        [ Form.form []
            [ Form.group []
                [ Form.label [] [ text "Name" ]
                , Input.text [ value model.name, onInput Name ]
                ]
            , Form.group []
                [ Form.label [] [ text "Email" ]
                , Input.email [ value model.email, onInput Email ]
                ]
            , Button.button [ primary, onClick UpdateProfile, disabled (cantUpdateProfile model) ]
                (if model.profileState == Just Loading then
                    [ Spinner.spinner [ Spinner.small, Spinner.attrs [ class "mr-2" ] ] []
                    , text "Update Profile"
                    ]

                 else
                    [ text "Update Profile" ]
                )
            ]
        ]


passwordView : Model -> List (Html Msg)
passwordView model =
    ListUtil.append3
        [ h3 [ class "mb-3" ] [ text "Password" ]
        ]
        (case model.passwordState of
            Just (Failure error) ->
                [ Alert.simpleDanger []
                    [ text ("Password update failed: " ++ error) ]
                ]

            _ ->
                []
        )
        [ Form.form []
            [ Form.group []
                [ Form.label [] [ text "Current Password" ]
                , Input.password [ value model.curPassword, onInput CurPassword ]
                ]
            , Form.group []
                [ Form.label [] [ text "New Password" ]
                , Input.password [ value model.password1, onInput Password1 ]
                ]
            , Form.group []
                [ Form.label [] [ text "Confirm Password" ]
                , Input.password [ value model.password2, onInput Password2 ]
                ]
            , Button.button [ primary, onClick UpdatePassword, disabled (cantUpdatePassword model) ]
                (if model.passwordState == Just Loading then
                    [ Spinner.spinner [ Spinner.small, Spinner.attrs [ class "mr-2" ] ] []
                    , text "Update Password"
                    ]

                 else
                    [ text "Update Password" ]
                )
            ]
        ]
