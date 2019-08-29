module Config exposing (productApi, title, userApi)


title : String
title =
    "HoshiLe’s Store"


apiBase : String
apiBase =
    "http://localhost:3000/"


productApi : String
productApi =
    apiBase ++ "products"


userApi : String
userApi =
    apiBase ++ "user"
