module Scenes.Home.Layer0.Global exposing
    ( dToCT
    , ctTod
    , getLayerCT
    )

{-| This is the doc for this module

@docs dToCT

@docs ctTod

@docs getLayerCT

-}

import Base exposing (GlobalData, Msg)
import Canvas exposing (Renderable)
import Lib.Layer.Base exposing (..)
import Scenes.Home.Layer0.Export exposing (Data, nullData)
import Scenes.Home.LayerBase exposing (CommonData)
import Scenes.Home.LayerSettings exposing (..)


{-| dToCT
-}
dToCT : Data -> LayerDataType
dToCT data =
    Layer0Data data


{-| ctTod
-}
ctTod : LayerDataType -> Data
ctTod ldt =
    case ldt of
        Layer0Data x ->
            x

        _ ->
            nullData


{-| getLayerCT
-}
getLayerCT : Layer CommonData Data -> LayerT
getLayerCT layer =
    let
        init : Int -> LayerMsg -> CommonData -> LayerDataType
        init t lm cd =
            dToCT (layer.init t lm cd)

        update : Msg -> GlobalData -> LayerMsg -> ( LayerDataType, Int ) -> CommonData -> ( ( LayerDataType, CommonData, List ( LayerTarget, LayerMsg ) ), GlobalData )
        update m gd lm ( ldt, t ) cd =
            let
                ( ( rldt, rcd, ltm ), newgd ) =
                    layer.update m gd lm ( ctTod ldt, t ) cd
            in
            ( ( dToCT rldt, rcd, ltm ), newgd )

        view : ( LayerDataType, Int ) -> CommonData -> GlobalData -> Renderable
        view ( ldt, t ) cd gd =
            layer.view ( ctTod ldt, t ) cd gd
    in
    Layer (dToCT layer.data) init update view
