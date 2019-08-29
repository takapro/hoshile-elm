module Util.FetchState exposing (FetchState(..))


type FetchState t
    = Loading
    | Success t
    | Failure String
