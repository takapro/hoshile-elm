module Entity.CartEntry exposing (CartEntry, DetailEntry, decoder, joinProducts, mergeCart, totalPrice)

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
