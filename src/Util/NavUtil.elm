module Util.NavUtil exposing (Model, href, init, parse, push, replace)

import Browser.Navigation as Nav
import Html
import Html.Attributes
import Route exposing (Route)
import Url exposing (Url)
import Url.Parser


type alias Model =
    { key : Nav.Key
    , basePath : String
    , baseList : List String
    }


init : Nav.Key -> String -> Model
init key basePath =
    let
        list =
            String.split "/" basePath
                |> List.filter (\s -> s /= "")

        path =
            list
                |> List.map (\s -> "/" ++ s)
                |> String.concat
    in
    Model key path list


parse : Model -> Url -> Maybe Route
parse { baseList } url =
    Url.Parser.parse (Route.pathParser baseList Route.parser) url


href : Model -> String -> Html.Attribute msg
href { basePath } path =
    Html.Attributes.href (basePath ++ path)


push : Model -> String -> Cmd msg
push { key, basePath } path =
    Nav.pushUrl key (basePath ++ path)


replace : Model -> String -> Cmd msg
replace { key, basePath } path =
    Nav.replaceUrl key (basePath ++ path)
