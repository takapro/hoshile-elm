module Config exposing (productApi)


apiBase =
    "http://localhost:3000/"


productApi =
    apiBase ++ "products"
