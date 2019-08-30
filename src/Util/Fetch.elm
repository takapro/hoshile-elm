module Util.Fetch exposing (FetchState(..), get, getWithToken, post, postWithToken, putWithToken)

import Http
import Json.Decode exposing (Decoder)
import Json.Encode exposing (Value)


type FetchState t
    = Loading
    | Success t
    | Failure String


get : (FetchState a -> msg) -> Decoder a -> String -> Cmd msg
get msg decoder url =
    Http.get
        { url = url
        , expect = Http.expectJson (update msg) decoder
        }


post : (FetchState a -> msg) -> Decoder a -> String -> Value -> Cmd msg
post msg decoder url value =
    Http.post
        { url = url
        , body = Http.jsonBody value
        , expect = Http.expectJson (update msg) decoder
        }


getWithToken : (FetchState a -> msg) -> Decoder a -> String -> String -> Cmd msg
getWithToken msg decoder url token =
    request "GET" msg decoder url token Http.emptyBody


postWithToken : (FetchState a -> msg) -> Decoder a -> String -> String -> Value -> Cmd msg
postWithToken msg decoder url token value =
    request "POST" msg decoder url token (Http.jsonBody value)


putWithToken : (FetchState a -> msg) -> Decoder a -> String -> String -> Value -> Cmd msg
putWithToken msg decoder url token value =
    request "PUT" msg decoder url token (Http.jsonBody value)


request : String -> (FetchState a -> msg) -> Decoder a -> String -> String -> Http.Body -> Cmd msg
request method msg decoder url token body =
    Http.request
        { method = method
        , headers =
            List.append
                [ Http.header "Authorization" ("Bearer " ++ token)
                , Http.header "Accept" "application/json"
                ]
                (if body == Http.emptyBody then
                    []

                 else
                    [ Http.header "Content-Type" "application/json"
                    ]
                )
        , url = url
        , body = body
        , expect = Http.expectJson (update msg) decoder
        , timeout = Nothing
        , tracker = Nothing
        }


update : (FetchState a -> msg) -> Result.Result Http.Error a -> msg
update msg result =
    case result of
        Ok value ->
            msg (Success value)

        Err error ->
            msg (Failure (Debug.toString error))
