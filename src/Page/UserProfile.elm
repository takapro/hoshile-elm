module Page.UserProfile exposing (Model, Msg, init, update, view)

import Bootstrap.Button as Button exposing (disabled, onClick, primary)
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input exposing (onInput, value)
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Entity.User as User exposing (User)
import Html exposing (Html, h3, hr, text)
import Html.Attributes exposing (class)
import Json.Encode as Encode
import Return exposing (Return, return, withCmd, withSessionMsg)
import Session
import Shared exposing (Shared)
import Util.Api as Api
import Util.Fetch as Fetch exposing (FetchState(..))
import Util.ListUtil as ListUtil
import View.CustomAlert as CustomAlert


type alias Model =
    { fetchState : Maybe (FetchState User)
    , name : String
    , email : String
    , curPassword : String
    , password1 : String
    , password2 : String
    , profileState : Maybe (FetchState User)
    , passwordState : Maybe (FetchState User)
    }


type Msg
    = Receive (FetchState User)
    | Name String
    | Email String
    | CurPassword String
    | Password1 String
    | Password2 String
    | UpdateProfile
    | ReceiveProfile (FetchState User)
    | UpdatePassword
    | ReceivePassword (FetchState User)


init : Shared t -> Return Model Msg msg
init { config, session } =
    case session.user of
        Just { token } ->
            return (Model (Just Loading) "" "" "" "" "" Nothing Nothing)
                |> withCmd (Fetch.getWithToken Receive User.decoder token (Api.user config "profile"))

        Nothing ->
            return (Model Nothing "" "" "" "" "" Nothing Nothing)


update : Msg -> Shared t -> Model -> Return Model Msg Session.Msg
update msg shared model =
    case msg of
        Receive ((Success user) as fetchState) ->
            return
                { model
                    | fetchState = Just fetchState
                    , name = user.name
                    , email = user.email
                }
                |> withSessionMsg (Session.Update user)

        Receive fetchState ->
            return { model | fetchState = Just fetchState }

        Name name ->
            return { model | name = name }

        Email email ->
            return { model | email = email }

        CurPassword curPassword ->
            return { model | curPassword = curPassword }

        Password1 password1 ->
            return { model | password1 = password1 }

        Password2 password2 ->
            return { model | password2 = password2 }

        UpdateProfile ->
            return { model | profileState = Just Loading }
                |> withCmd (profileCmd shared model)

        ReceiveProfile ((Success user) as fetchState) ->
            return { model | profileState = Just fetchState }
                |> withSessionMsg (Session.Update user)

        ReceiveProfile fetchState ->
            return { model | profileState = Just fetchState }

        UpdatePassword ->
            return { model | passwordState = Just Loading }
                |> withCmd (passwordCmd shared model)

        ReceivePassword ((Success user) as fetchState) ->
            return { model | passwordState = Just fetchState }
                |> withSessionMsg (Session.Update user)

        ReceivePassword fetchState ->
            return { model | passwordState = Just fetchState }


cantUpdateProfile : Model -> Bool
cantUpdateProfile { name, email, profileState } =
    name == "" || email == "" || profileState == Just Loading


cantUpdatePassword : Model -> Bool
cantUpdatePassword { curPassword, password1, password2, passwordState } =
    curPassword == "" || password1 == "" || password1 /= password2 || passwordState == Just Loading


profileCmd : Shared t -> Model -> Cmd Msg
profileCmd { config, session } { name, email } =
    case session.user of
        Just { token } ->
            Fetch.putWithToken ReceiveProfile User.decoder token (Api.user config "profile") <|
                Encode.object
                    [ ( "name", Encode.string name )
                    , ( "email", Encode.string email )
                    ]

        Nothing ->
            Cmd.none


passwordCmd : Shared t -> Model -> Cmd Msg
passwordCmd { config, session } { curPassword, password1 } =
    case session.user of
        Just { token } ->
            Fetch.putWithToken ReceivePassword User.decoder token (Api.user config "password") <|
                Encode.object
                    [ ( "curPassword", Encode.string curPassword )
                    , ( "newPassword", Encode.string password1 )
                    ]

        Nothing ->
            Cmd.none


view : Shared t -> Model -> Html Msg
view _ model =
    Grid.container [ class "py-4" ]
        (CustomAlert.maybeFetchState "Not logged in." "Fetch" model.fetchState <|
            \_ ->
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
        (CustomAlert.successOrError "Profile update" model.profileState)
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
        (CustomAlert.successOrError "Password update" model.passwordState)
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
