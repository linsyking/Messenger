module Scenes.$0.LayerSettings exposing
    ( LayerDataType(..)
    , LayerT
    )

{-| This is the doc for this module

@docs LayerDataType

@docs LayerT

-}

import Lib.Layer.Base exposing (..)
import Scenes.$0.LayerBase exposing (CommonData)
$1


{-| LayerDataType
-}
type LayerDataType
    = $2
    | NullLayerData


{-| LayerT
-}
type alias LayerT =
    Layer CommonData LayerDataType
