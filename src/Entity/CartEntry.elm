module Entity.CartEntry exposing (CartEntry, DetailEntry, decoder, detailEntries, totalPrice)

import Entity.Product exposing (Product)
import Json.Decode exposing (Decoder, field, int, map2)


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
        (field "productId" int)
        (field "quantity" int)


detailEntries : List CartEntry -> List Product -> List DetailEntry
detailEntries entries products =
    entries
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
