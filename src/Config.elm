module Config exposing (productApi, title)


title : String
title =
    "HoshiLe’s Store"


apiBase : String
apiBase =
    "http://localhost:3000/"


productApi : String
productApi =
    apiBase ++ "products"
