module Components.B.B exposing (..)

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
updateModel _ gd tmsg ( d, t ) =
    case tmsg of
        ComponentIntMsg x ->
            let
                test =
                    Debug.log "B" x
            in
            ( d
            , [ if x >= 0 then
                    ( ComponentByName "A", ComponentIntMsg (x - 1) )

                else
                    ( ComponentParentLayer, ComponentIntMsg 0 )
              ]
            , gd
            )

        _ ->
            if t == 60 then
                ( d, [ ( ComponentByName "B", ComponentIntMsg 10 ), ( ComponentParentLayer, ComponentStringMsg "Hi" ) ], gd )

            else
                ( d, [], gd )
