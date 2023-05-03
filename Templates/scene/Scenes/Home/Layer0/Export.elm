module Scenes.Home.Layer0.Export exposing
    ( Data
    , nullData
    , layer
    )

{-| This is the doc for this module

@docs Data

@docs nullData

@docs layer

-}

import Array
import Lib.Layer.Base exposing (..)
import Scenes.Home.Layer0.Common exposing (Model)
import Scenes.Home.Layer0.Display exposing (dview)
import Scenes.Home.Layer0.Models exposing (initModel, updateModel)
import Scenes.Home.LayerBase exposing (CommonData)


{-| Data
-}
type alias Data =
    Model


{-| nullData
-}
nullData : Data
nullData =
    { components = Array.empty
    }


{-| layer
-}
layer : Layer CommonData Data
layer =
    { data = nullData
    , init = initModel
    , update = updateModel
    , view = dview
    }
