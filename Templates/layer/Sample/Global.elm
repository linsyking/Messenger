module Scenes.$0.$1.Global exposing
    ( dataToLDT
    , ldtToData
    , getLayerT
    )

{-| This is the doc for this module

@docs dataToLDT

@docs ldtToData

@docs getLayerT

-}

import Base exposing (GlobalData, Msg)
import Canvas exposing (Renderable)
import Lib.Layer.Base exposing (..)
import Scenes.$0.$1.Export exposing (Data, nullData)
import Scenes.$0.LayerBase exposing (CommonData)
import Scenes.$0.LayerSettings exposing (..)


{-| dataToLDT
-}
dataToLDT : Data -> LayerDataType
dataToLDT data =
    $1Data data


{-| ldtToData
-}
ldtToData : LayerDataType -> Data
ldtToData ldt =
    case ldt of
        $1Data x ->
            x

        _ ->
            nullData


{-| getLayerT
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
