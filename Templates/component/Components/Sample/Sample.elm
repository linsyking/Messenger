module Components.$0.$0 exposing (..)

{-| initModel
-}

import Base exposing (GlobalData, Msg)
import Canvas exposing (Renderable, group)
import Dict
import Lib.Component.Base exposing (ComponentTMsg(..), ComponentTarget(..), Data, DefinedTypes(..))


initModel : Int -> Int -> ComponentTMsg -> Data
initModel _ id _ =
    Dict.fromList
        [ ( "id", CDInt id )
        ]


{-| updateModel
-}
updateModel : Msg -> GlobalData -> ComponentTMsg -> ( Data, Int ) -> ( Data, List ( ComponentTarget, ComponentTMsg ), GlobalData )
updateModel _ gd _ ( d, _ ) =
    ( d, [], gd )


{-| viewModel
-}
viewModel : ( Data, Int ) -> GlobalData -> Renderable
viewModel _ _ =
    group [] []
