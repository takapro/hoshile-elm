module View.CustomAlert exposing (error, errorIfFailure, fetchState, loading, maybeFetchState, spinnerLabel, successOrError)

import Bootstrap.Alert as Alert
import Bootstrap.Button as Button
import Bootstrap.Spinner as Spinner
import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
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


errorWithRelooad : String -> msg -> Html msg
errorWithRelooad message reload =
    Alert.simpleDanger [ class "d-flex align-items-center" ]
        [ div [ class "flex-grow-1" ] [ text message ]
        , div []
            [ Button.button
                [ Button.small, Button.outlineDanger, Button.attrs [ onClick reload ] ]
                [ text "Reload" ]
            ]
        ]


errorIfFailure : String -> Maybe (FetchState t) -> List (Html msg)
errorIfFailure action state =
    case state of
        Just (Failure message) ->
            [ error (action ++ " failed: " ++ message) ]

        _ ->
            []


successOrError : String -> Maybe (FetchState t) -> List (Html msg)
successOrError action state =
    case state of
        Just (Success _) ->
            [ Alert.simpleSuccess [] [ text (action ++ " succeeded.") ] ]

        _ ->
            errorIfFailure action state


fetchState : String -> FetchState t -> msg -> (t -> List (Html msg)) -> List (Html msg)
fetchState action state reload success =
    case state of
        Loading ->
            [ loading "Loading..." ]

        Failure message ->
            [ errorWithRelooad (action ++ " failed: " ++ message) reload ]

        Success value ->
            success value


maybeFetchState : String -> String -> Maybe (FetchState t) -> msg -> (t -> List (Html msg)) -> List (Html msg)
maybeFetchState message action maybeState reload success =
    case maybeState of
        Nothing ->
            [ error message ]

        Just state ->
            fetchState action state reload success


spinnerLabel : Maybe (FetchState t) -> String -> List (Html msg)
spinnerLabel maybeState label =
    case maybeState of
        Just Loading ->
            [ Spinner.spinner [ Spinner.small, Spinner.attrs [ class "mr-2" ] ] []
            , text label
            ]

        _ ->
            [ text label ]
