module Config exposing (Config, Flags, init, order, orders, product, products, shoppingCart, userLogin, userPassword, userProfile, userSignup)

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


products : Config -> String
products { apiBase } =
    apiBase ++ "products"


product : Config -> Int -> String
product { apiBase } id =
    apiBase ++ "products" ++ "/" ++ String.fromInt id


userLogin : Config -> String
userLogin { apiBase } =
    apiBase ++ "user/login"


userSignup : Config -> String
userSignup { apiBase } =
    apiBase ++ "user/signup"


userProfile : Config -> String
userProfile { apiBase } =
    apiBase ++ "user/profile"


userPassword : Config -> String
userPassword { apiBase } =
    apiBase ++ "user/password"


shoppingCart : Config -> String
shoppingCart { apiBase } =
    apiBase ++ "user/shoppingCart"


orders : Config -> String
orders { apiBase } =
    apiBase ++ "orders"


order : Config -> Int -> String
order { apiBase } id =
    apiBase ++ "orders" ++ "/" ++ String.fromInt id
