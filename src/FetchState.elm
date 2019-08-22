module FetchState exposing (FetchMsg(..), FetchState(..), productApi, updateFetch)

import Http


apiBase =
    "http://localhost/HoshiLe/"


productApi =
    apiBase ++ "ProductAPI.php"


type FetchState t
    = FetchNone
    | FetchLoading
    | FetchSuccess t
    | FetchFailed String


type FetchMsg t
    = Fetch
    | Receive (Result Http.Error t)


updateFetch : FetchMsg t -> Cmd msg -> ( FetchState t, Cmd msg )
updateFetch msg fetch =
    case msg of
        Fetch ->
            ( FetchLoading, fetch )

        Receive (Ok result) ->
            ( FetchSuccess result, Cmd.none )

        Receive (Err error) ->
            ( FetchFailed (Debug.toString error), Cmd.none )
