module Shared exposing (Shared)

import Bootstrap.Navbar as Navbar
import Config exposing (Config)
import Session exposing (Session)


type alias Shared t =
    { t
        | config : Config
        , session : Session
        , navState : Navbar.State
    }
