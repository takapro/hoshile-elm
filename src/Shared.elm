module Shared exposing (Shared)

import Config exposing (Config)
import Session exposing (Session)


type alias Shared t =
    { t
        | config : Config
        , session : Session
    }
