module Page.UserProfile exposing (Model, Msg, init, update, view)

import Bootstrap.Button as Button exposing (disabled, onClick, primary)
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input exposing (onInput, value)
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Config
import Entity.User as User exposing (User)
import Html exposing (Html, h3, hr, text)
import Html.Attributes exposing (class)
import Json.Encode as Encode
import Session
import Util.Fetch as Fetch exposing (FetchState(..))
import Util.ListUtil as ListUtil
import View.CustomAlert as CustomAlert


type alias Model =
    { token : Maybe String
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
    | ReceiveProfile (FetchState User)
    | UpdatePassword
    | ReceivePassword (FetchState User)


init : Maybe User -> ( Model, Cmd Msg )
init user =
    case user of
        Just { token, name, email } ->
            ( Model (Just token) name email "" "" "" Nothing Nothing, Cmd.none )

        Nothing ->
            ( Model Nothing "" "" "" "" "" Nothing Nothing, Cmd.none )


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

        ReceiveProfile (Success user) ->
            ( { model | profileState = Nothing }, sessionCmd (Session.Update user) )

        ReceiveProfile fetchState ->
            ( { model | profileState = Just fetchState }, Cmd.none )

        UpdatePassword ->
            ( { model | passwordState = Just Loading }, Cmd.map wrapMsg (passwordCmd model) )

        ReceivePassword (Success user) ->
            ( { model | passwordState = Nothing }, sessionCmd (Session.Update user) )

        ReceivePassword fetchState ->
            ( { model | passwordState = Just fetchState }, Cmd.none )


cantUpdateProfile : Model -> Bool
cantUpdateProfile { name, email, profileState } =
    name == "" || email == "" || profileState == Just Loading


cantUpdatePassword : Model -> Bool
cantUpdatePassword { curPassword, password1, password2, passwordState } =
    curPassword == "" || password1 == "" || password1 /= password2 || passwordState == Just Loading


profileCmd : Model -> Cmd Msg
profileCmd model =
    case model.token of
        Just token ->
            Fetch.putWithToken ReceiveProfile User.decoder (Config.userApi ++ "/profile") token <|
                Encode.object
                    [ ( "name", Encode.string model.name )
                    , ( "email", Encode.string model.email )
                    ]

        Nothing ->
            Cmd.none


passwordCmd : Model -> Cmd Msg
passwordCmd model =
    case model.token of
        Just token ->
            Fetch.putWithToken ReceivePassword User.decoder (Config.userApi ++ "/password") token <|
                Encode.object
                    [ ( "curPassword", Encode.string model.curPassword )
                    , ( "newPassword", Encode.string model.password1 )
                    ]

        Nothing ->
            Cmd.none


view : Model -> Html Msg
view model =
    Grid.container [ class "py-4" ]
        (if model.token == Nothing then
            [ CustomAlert.error "Not logged in." ]

         else
            [ Grid.row [ Row.attrs [ class "justify-content-center" ] ]
                [ Grid.col [ Col.md6 ]
                    (ListUtil.append3
                        (profileView model)
                        [ hr [ class "my-4" ] [] ]
                        (passwordView model)
                    )
                ]
            ]
        )


profileView : Model -> List (Html Msg)
profileView model =
    ListUtil.append3
        [ h3 [ class "mb-3" ] [ text "Profile" ]
        ]
        (CustomAlert.errorIfFailure "Profile update" model.profileState)
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
                (CustomAlert.spinnerLabel model.profileState "Update Profile")
            ]
        ]


passwordView : Model -> List (Html Msg)
passwordView model =
    ListUtil.append3
        [ h3 [ class "mb-3" ] [ text "Password" ]
        ]
        (CustomAlert.errorIfFailure "Password update" model.passwordState)
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
                (CustomAlert.spinnerLabel model.passwordState "Update Password")
            ]
        ]
