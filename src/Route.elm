module Route exposing (Route(..), parse)

import Url exposing (Url)
import Url.Parser exposing ((</>), Parser, int, map, oneOf, s, top)


type Route
    = Top
    | Product Int


parse : Url -> Maybe Route
parse url =
    Url.Parser.parse parser url


parser : Parser (Route -> a) a
parser =
    oneOf
        [ map Top top
        , map Product (s "product" </> int)
        ]
