module RouteTest exposing (suite)

import Expect
import Route exposing (Route)
import Test exposing (Test, describe, test)
import Url exposing (Url)


testParse : String -> String -> Maybe Route -> Test
testParse name path expected =
    test ("should parse " ++ name) <|
        \_ ->
            Url.fromString ("http://example.com" ++ path)
                |> Maybe.andThen Route.parse
                |> Expect.equal expected


suite : Test
suite =
    describe "Route"
        [ testParse "ProductList" "/" (Just Route.Top)
        , testParse "ProductDetail 1" "/product/1" (Just (Route.Product 1))
        , testParse "Invalid /product" "/product" Nothing
        , testParse "Invalid /product/x" "/product/x" Nothing
        , testParse "About" "/about" (Just Route.About)
        , testParse "Login Nothing" "/login" (Just (Route.Login Nothing))
        , testParse "Login forPurchase=true" "/login?forPurchase=true" (Just (Route.Login (Just "true")))
        , testParse "Login forPurchaseX=false" "/login?forPurchaseX=false" (Just (Route.Login Nothing))
        , testParse "Logout" "/logout" (Just Route.Logout)
        , testParse "Signup Nothing" "/signup" (Just (Route.Signup Nothing))
        , testParse "Signup forPurchase=true" "/signup?forPurchase=true" (Just (Route.Signup (Just "true")))
        , testParse "Signup forPurchaseX=false" "/signup?forPurchaseX=false" (Just (Route.Signup Nothing))
        , testParse "Profile" "/profile" (Just Route.Profile)
        , testParse "ShoppingCart" "/shoppingCart" (Just Route.ShoppingCart)
        , testParse "Invalid /zzz" "/zzz" Nothing
        ]
