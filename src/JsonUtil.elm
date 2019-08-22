module JsonUtil exposing (stringToFloat, stringToInt)

import Json.Decode exposing (Decoder, andThen, fail, float, int, oneOf, string, succeed)


stringToInt : Decoder Int
stringToInt =
    oneOf [ int, decodeWith String.toInt ]


stringToFloat : Decoder Float
stringToFloat =
    oneOf [ float, decodeWith String.toFloat ]


decodeWith : (String -> Maybe t) -> Decoder t
decodeWith convert =
    string
        |> andThen
            (\str ->
                case convert str of
                    Just value ->
                        succeed value

                    Nothing ->
                        fail "Failed to convert"
            )
