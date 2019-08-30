module Entity.User exposing (User, decoder)

import Json.Decode exposing (Decoder, bool, field, map5, string)


type alias User =
    { token : String
    , name : String
    , email : String
    , shoppingCart : String
    , isAdmin : Bool
    }


decoder : Decoder User
decoder =
    map5 User
        (field "token" string)
        (field "name" string)
        (field "email" string)
        (field "shoppingCart" string)
        (field "isAdmin" bool)
