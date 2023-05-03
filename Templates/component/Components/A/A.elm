module Components.A.A exposing (..)

{-| initModel
-}

import Base exposing (GlobalData, Msg)
import Dict
import Lib.Component.Base exposing (ComponentTMsg(..), ComponentTarget(..), Data, DefinedTypes(..))


initModel : Int -> Int -> ComponentTMsg -> Data
initModel _ id _ =
    Dict.fromList
        [ ( "val", CDInt 0 )
        , ( "id", CDInt id )
        ]


{-| updateModel
-}
updateModel : Msg -> GlobalData -> ComponentTMsg -> ( Data, Int ) -> ( Data, List ( ComponentTarget, ComponentTMsg ), GlobalData )
updateModel _ gd tmsg ( d, _ ) =
    case tmsg of
        ComponentIntMsg x ->
            let
                test =
                    Debug.log "A" x
            in
            ( d, [ ( ComponentByName "B", ComponentIntMsg (x - 2) ) ], gd )

        _ ->
            ( d, [], gd )
