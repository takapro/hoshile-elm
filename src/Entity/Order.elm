module Entity.Order exposing (OrderDetail, OrderHead, decoder, totalPrice)

import Entity.Product as Product exposing (Product)
import Json.Decode exposing (Decoder, field, list, map4, map5, string)
import Util.JsonUtil exposing (stringToInt)


type alias OrderHead =
    { id : Int
    , userId : Int
    , createDate : String
    , details : List OrderDetail
    }


type alias OrderDetail =
    { id : Int
    , orderId : Int
    , productId : Int
    , quantity : Int
    , product : Product
    }


decoder : Decoder OrderHead
decoder =
    map4 OrderHead
        (field "id" stringToInt)
        (field "userId" stringToInt)
        (field "createDate" string)
        (field "details" (list detailDecoder))


detailDecoder : Decoder OrderDetail
detailDecoder =
    map5 OrderDetail
        (field "id" stringToInt)
        (field "orderId" stringToInt)
        (field "productId" stringToInt)
        (field "quantity" stringToInt)
        (field "product" Product.decoder)


totalPrice : List OrderDetail -> Float
totalPrice details =
    details
        |> List.map (\{ product, quantity } -> product.price * toFloat quantity)
        |> List.sum
