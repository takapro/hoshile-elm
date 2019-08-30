module Config exposing (productApi, title, userApi)


title : String
title =
    "HoshiLe’s Store"


apiBase : String
apiBase =
    "https://hoshile-api.herokuapp.com/"


productApi : String
productApi =
    apiBase ++ "products"


userApi : String
userApi =
    apiBase ++ "user"
