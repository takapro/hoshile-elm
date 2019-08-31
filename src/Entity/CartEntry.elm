module Entity.CartEntry exposing (CartEntry, DetailEntry, decoder, encodeCart, joinProducts, mergeCart, totalPrice)

import Entity.Product exposing (Product)
import Json.Decode exposing (Decoder, field, int, map2)
import Json.Encode as Encode exposing (Value)
import Util.JsonUtil exposing (stringToInt)


type alias CartEntry =
    { productId : Int
    , quantity : Int
    }


type alias DetailEntry =
    { product : Product
    , quantity : Int
    }


decoder : Decoder CartEntry
decoder =
    map2 CartEntry
        (field "productId" stringToInt)
        (field "quantity" stringToInt)


encodeCart : List CartEntry -> Value
encodeCart cart =
    cart
        |> Encode.list
            (\entry ->
                Encode.object
                    [ ( "productId", Encode.int entry.productId )
                    , ( "quantity", Encode.int entry.quantity )
                    ]
            )


mergeCart : List CartEntry -> List CartEntry -> List CartEntry
mergeCart cart1 cart2 =
    List.foldl mergeEntry cart1 cart2
        |> List.filter (\entry -> entry.quantity > 0)


mergeEntry : CartEntry -> List CartEntry -> List CartEntry
mergeEntry entry cart =
    case cart of
        [] ->
            [ entry ]

        head :: rest ->
            if head.productId == entry.productId then
                { head | quantity = head.quantity + entry.quantity } :: rest

            else
                head :: mergeEntry entry rest


joinProducts : List CartEntry -> List Product -> List DetailEntry
joinProducts cart products =
    cart
        |> List.map
            (\entry ->
                products
                    |> List.filter (\product -> product.id == entry.productId)
                    |> List.map (\product -> DetailEntry product entry.quantity)
            )
        |> List.concat


totalPrice : List DetailEntry -> Float
totalPrice entries =
    entries
        |> List.map (\{ product, quantity } -> product.price * toFloat quantity)
        |> List.sum
