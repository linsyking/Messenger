module Scenes.$0.Export exposing
    ( Data
    , nullData
    , scene
    )

{-| This is the doc for this module

@docs Data

@docs nullData

@docs scene

-}

import Lib.Scene.Base exposing (..)
import Scenes.$0.Common exposing (Model)
import Scenes.$0.LayerBase exposing (initCommonData)
import Scenes.$0.Model exposing (initModel, updateModel, viewModel)


{-| Data
-}
type alias Data =
    Model


{-| nullData
-}
nullData : Data
nullData =
    { commonData = initCommonData
    , layers = []
    }


{-| scene
-}
scene : Scene Data
scene =
    { init = initModel
    , update = updateModel
    , view = viewModel
    }
