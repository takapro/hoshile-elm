module Product exposing (Product, fetchProductList)

import FetchState exposing (FetchMsg(..), productApi)
import Http
import Json.Decode exposing (Decoder, field, list, map5, string)
import JsonUtil exposing (stringToFloat, stringToInt)


type alias Product =
    { id : Int
    , name : String
    , brand : String
    , price : Float
    , imageUrl : String
    }


fetchProductList : (FetchMsg (List Product) -> msg) -> Cmd msg
fetchProductList toMsg =
    Http.get
        { url = productApi
        , expect = Http.expectJson (Receive >> toMsg) (list productDecoder)
        }


productDecoder : Decoder Product
productDecoder =
    map5 Product
        (field "id" stringToInt)
        (field "name" string)
        (field "brand" string)
        (field "price" stringToFloat)
        (field "imageUrl" string)
