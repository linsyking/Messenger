module Scenes.Home.Layer1.Global exposing
    ( dataToLDT
    , getLayerT
    , ldtToData
    )

{-| This is the doc for this module

@docs dToCT

@docs ctTod

@docs getLayerCT

-}

import Base exposing (GlobalData, Msg)
import Canvas exposing (Renderable)
import Lib.Layer.Base exposing (..)
import Scenes.Home.Layer1.Export exposing (Data, nullData)
import Scenes.Home.LayerBase exposing (CommonData)
import Scenes.Home.LayerSettings exposing (..)


{-| dToCT
-}
dataToLDT : Data -> LayerDataType
dataToLDT data =
    Layer1Data data


{-| ctTod
-}
ldtToData : LayerDataType -> Data
ldtToData ldt =
    case ldt of
        Layer1Data x ->
            x

        _ ->
            nullData


{-| getLayerCT
-}
getLayerT : Layer CommonData Data -> LayerT
getLayerT layer =
    let
        init : Int -> LayerMsg -> CommonData -> LayerDataType
        init t lm cd =
            dataToLDT (layer.init t lm cd)

        update : Msg -> GlobalData -> LayerMsg -> ( LayerDataType, Int ) -> CommonData -> ( ( LayerDataType, CommonData, List ( LayerTarget, LayerMsg ) ), GlobalData )
        update m gd lm ( ldt, t ) cd =
            let
                ( ( rldt, rcd, ltm ), newgd ) =
                    layer.update m gd lm ( ldtToData ldt, t ) cd
            in
            ( ( dataToLDT rldt, rcd, ltm ), newgd )

        view : ( LayerDataType, Int ) -> CommonData -> GlobalData -> Renderable
        view ( ldt, t ) cd gd =
            layer.view ( ldtToData ldt, t ) cd gd
    in
    Layer (dataToLDT layer.data) init update view
