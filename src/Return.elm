module Return exposing (Return, mapEffects, return, withCmd, withSessionMsg)


type alias Return model msg sessionMsg =
    { model : model
    , effects : List (Effect msg sessionMsg)
    }


type Effect msg sessionMsg
    = PageCmd (Cmd msg)
    | SessionMsg sessionMsg


return : model -> Return model msg sessionMsg
return model =
    Return model []


withCmd : Cmd msg -> Return model msg sessionMsg -> Return model msg sessionMsg
withCmd cmd ret =
    { ret | effects = ret.effects ++ [ PageCmd cmd ] }


withSessionMsg : sessionMsg -> Return model msg sessionMsg -> Return model msg sessionMsg
withSessionMsg msg ret =
    { ret | effects = ret.effects ++ [ SessionMsg msg ] }


mapEffects : (msg -> appMsg) -> (sessionMsg -> Cmd appMsg) -> List (Effect msg sessionMsg) -> Cmd appMsg
mapEffects toMsg sessionCmd effects =
    effects
        |> List.map
            (\effect ->
                case effect of
                    PageCmd cmd ->
                        Cmd.map toMsg cmd

                    SessionMsg msg ->
                        sessionCmd msg
            )
        |> Cmd.batch
