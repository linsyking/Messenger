module Scenes.Home.LayerSettings exposing
    ( LayerDataType(..)
    , LayerT
    )

{-| This is the doc for this module

@docs LayerDataType

@docs LayerCT

-}

import Lib.Layer.Base exposing (..)
import Scenes.Home.Layer0.Export as L0
import Scenes.Home.Layer1.Export as L1
import Scenes.Home.LayerBase exposing (CommonData)


{-| LayerDataType
-}
type LayerDataType
    = Layer0Data L0.Data
    | Layer1Data L1.Data
    | NullLayerData


{-| LayerCT
-}
type alias LayerT =
    Layer CommonData LayerDataType
