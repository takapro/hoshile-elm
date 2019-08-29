module Entity.Product exposing (Product, decoder)

import Json.Decode exposing (Decoder, field, map5, string)
import Util.JsonUtil exposing (stringToFloat, stringToInt)


type alias Product =
    { id : Int
    , name : String
    , brand : String
    , price : Float
    , imageUrl : String
    }


decoder : Decoder Product
decoder =
    map5 Product
        (field "id" stringToInt)
        (field "name" string)
        (field "brand" string)
        (field "price" stringToFloat)
        (field "imageUrl" string)
