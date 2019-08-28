module Config exposing (productApi, title)


title =
    "HoshiLe’s Store"


apiBase =
    "http://localhost:3000/"


productApi =
    apiBase ++ "products"
