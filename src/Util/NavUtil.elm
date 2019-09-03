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


type alias NavConfig t =
    { t | nav : Model }


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


parse : NavConfig t -> Url -> Maybe Route
parse { nav } url =
    Url.Parser.parse (Route.pathParser nav.baseList Route.parser) url


href : NavConfig t -> String -> Html.Attribute msg
href { nav } path =
    Html.Attributes.href (nav.basePath ++ path)


push : NavConfig t -> String -> Cmd msg
push { nav } path =
    Nav.pushUrl nav.key (nav.basePath ++ path)


replace : NavConfig t -> String -> Cmd msg
replace { nav } path =
    Nav.replaceUrl nav.key (nav.basePath ++ path)
