module Util.Api exposing (order, orders, product, products, user)


type alias ApiConfig t =
    { t | apiBase : String }


products : ApiConfig t -> String
products { apiBase } =
    apiBase ++ "products"


product : ApiConfig t -> Int -> String
product { apiBase } id =
    apiBase ++ "products" ++ "/" ++ String.fromInt id


user : ApiConfig t -> String -> String
user { apiBase } fragment =
    apiBase ++ "user/" ++ fragment


orders : ApiConfig t -> String
orders { apiBase } =
    apiBase ++ "orders"


order : ApiConfig t -> Int -> String
order { apiBase } id =
    apiBase ++ "orders" ++ "/" ++ String.fromInt id
