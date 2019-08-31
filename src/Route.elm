module Route exposing (Route(..), parse)

import Url exposing (Url)
import Url.Parser exposing ((</>), (<?>), Parser, int, map, oneOf, s, top)
import Url.Parser.Query as Query


type Route
    = Top
    | Product Int
    | About
    | Login (Maybe String)
    | Logout
    | Signup (Maybe String)
    | Profile
    | ShoppingCart
    | OrderList
    | OrderDetail Int


parse : Url -> Maybe Route
parse url =
    Url.Parser.parse parser url


parser : Parser (Route -> a) a
parser =
    oneOf
        [ map Top top
        , map Product (s "product" </> int)
        , map About (s "about")
        , map Login (s "login" <?> Query.string "forPurchase")
        , map Logout (s "logout")
        , map Signup (s "signup" <?> Query.string "forPurchase")
        , map Profile (s "profile")
        , map ShoppingCart (s "shoppingCart")
        , map OrderList (s "orderList")
        , map OrderDetail (s "order" </> int)
        ]
