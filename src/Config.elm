module Config exposing (Config, Flags, init)

import Browser.Navigation as Nav
import Util.NavUtil as NavUtil


type alias Flags =
    { siteName : String
    , basePath : String
    , apiBase : String
    }


type alias Config =
    { title : String
    , nav : NavUtil.Model
    , apiBase : String
    }


init : Flags -> Nav.Key -> Config
init { siteName, basePath, apiBase } key =
    Config siteName (NavUtil.init key basePath) apiBase
