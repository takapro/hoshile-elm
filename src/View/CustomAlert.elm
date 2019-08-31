module View.CustomAlert exposing (error, errorIfFailure, fetchState, loading, maybeFetchState, spinnerLabel)

import Bootstrap.Alert as Alert
import Bootstrap.Spinner as Spinner
import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Util.Fetch exposing (FetchState(..))


loading : String -> Html msg
loading message =
    Alert.simpleLight [ class "d-flex align-items-center" ]
        [ Spinner.spinner [ Spinner.grow ] []
        , div [ class "ml-3" ] [ text message ]
        ]


error : String -> Html msg
error message =
    Alert.simpleDanger [] [ text message ]


errorIfFailure : String -> Maybe (FetchState t) -> List (Html msg)
errorIfFailure action state =
    case state of
        Just (Failure message) ->
            [ error (action ++ " failed: " ++ message) ]

        _ ->
            []


fetchState : String -> FetchState t -> (t -> List (Html msg)) -> List (Html msg)
fetchState action state success =
    case state of
        Loading ->
            [ loading "Loading..." ]

        Failure message ->
            [ error (action ++ " failed: " ++ message) ]

        Success value ->
            success value


maybeFetchState : String -> String -> Maybe (FetchState t) -> (t -> List (Html msg)) -> List (Html msg)
maybeFetchState message action maybeState success =
    case maybeState of
        Nothing ->
            [ error message ]

        Just state ->
            fetchState action state success


spinnerLabel : Maybe (FetchState t) -> String -> List (Html msg)
spinnerLabel maybeState label =
    case maybeState of
        Just Loading ->
            [ Spinner.spinner [ Spinner.small, Spinner.attrs [ class "mr-2" ] ] []
            , text label
            ]

        _ ->
            [ text label ]
