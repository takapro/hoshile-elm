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
        , testParse "Login" "/login" (Just Route.Login)
        , testParse "Logout" "/logout" (Just Route.Logout)
        , testParse "Signup" "/signup" (Just Route.Signup)
        , testParse "Profile" "/profile" (Just Route.Profile)
        , testParse "Invalid /zzz" "/zzz" Nothing
        ]
