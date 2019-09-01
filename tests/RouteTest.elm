module RouteTest exposing (test1, test2, test3)

import Expect
import Route exposing (Route)
import Test exposing (Test, describe, test)
import Url exposing (Url)
import Url.Parser


testParse : List String -> ( String, Maybe Route ) -> Test
testParse list ( path, expected ) =
    test path <|
        \_ ->
            Url.fromString ("http://example.com" ++ path)
                |> Maybe.map (Url.Parser.parse (Route.pathParser list Route.parser))
                |> Expect.equal (Just expected)


test1 : Test
test1 =
    describe "Route 1" <|
        List.map (testParse []) <|
            [ ( "/", Just Route.Top )
            , ( "/product/1", Just (Route.Product 1) )
            , ( "/product", Nothing )
            , ( "/product/x", Nothing )
            , ( "/about", Just Route.About )
            , ( "/login", Just (Route.Login Nothing) )
            , ( "/login?forPurchase=true", Just (Route.Login (Just "true")) )
            , ( "/login?forPurchaseX=false", Just (Route.Login Nothing) )
            , ( "/logout", Just Route.Logout )
            , ( "/signup", Just (Route.Signup Nothing) )
            , ( "/signup?forPurchase=true", Just (Route.Signup (Just "true")) )
            , ( "/signup?forPurchaseX=false", Just (Route.Signup Nothing) )
            , ( "/profile", Just Route.Profile )
            , ( "/shoppingCart", Just Route.ShoppingCart )
            , ( "/orderList", Just Route.OrderList )
            , ( "/order/1", Just (Route.OrderDetail 1) )
            , ( "/zzz", Nothing )
            ]


test2 : Test
test2 =
    describe "Route 2" <|
        List.map (testParse [ "product" ]) <|
            [ ( "/", Nothing )
            , ( "/1", Nothing )
            , ( "/product", Just Route.Top )
            , ( "/product/", Just Route.Top )
            , ( "/product/1", Nothing )
            , ( "/product/product", Nothing )
            , ( "/product/product/", Nothing )
            , ( "/product/product/1", Just (Route.Product 1) )
            , ( "/product/product/product", Nothing )
            , ( "/product/product/product/", Nothing )
            , ( "/product/product/product/1", Nothing )
            , ( "/product/product/product/product", Nothing )
            ]


test3 : Test
test3 =
    describe "Route 3" <|
        List.map (testParse [ "product", "product" ]) <|
            [ ( "/", Nothing )
            , ( "/1", Nothing )
            , ( "/product", Nothing )
            , ( "/product/", Nothing )
            , ( "/product/1", Nothing )
            , ( "/product/product", Just Route.Top )
            , ( "/product/product/", Just Route.Top )
            , ( "/product/product/1", Nothing )
            , ( "/product/product/product", Nothing )
            , ( "/product/product/product/", Nothing )
            , ( "/product/product/product/1", Just (Route.Product 1) )
            , ( "/product/product/product/product", Nothing )
            ]
