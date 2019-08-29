module Page.UserLogin exposing (Model, Msg, init, update, view)

import Bootstrap.Button as Button
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Html exposing (Html, h3, text)
import Html.Attributes exposing (class, for)


type alias Model =
    ()


type alias Msg =
    ()


init : ( Model, Cmd Msg )
init =
    ( (), Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


view : Model -> Html Msg
view model =
    Grid.container [ class "py-4" ]
        [ Grid.row [ Row.attrs [ class "justify-content-center" ] ]
            [ Grid.col [ Col.md6 ]
                ([ h3 [ class "mb-3" ] [ text "Please Log in" ]
                 ]
                    ++ (if True then
                            []

                        else
                            []
                       )
                    ++ [ Form.form []
                            [ Form.group []
                                [ Form.label [ for "email" ] [ text "Email" ]
                                , Input.email [ Input.id "email" ]
                                ]
                            , Form.group []
                                [ Form.label [ for "password" ] [ text "Password" ]
                                , Input.password [ Input.id "password" ]
                                ]
                            , Button.button [ Button.primary ] [ text "Log in" ]
                            ]
                       ]
                )
            ]
        ]
