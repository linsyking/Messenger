module Scenes.$0.Common exposing (Model)

{-| This is the doc for this module

@docs Model

-}

import Lib.Scene.Base exposing (LayerPacker)
import Scenes.$0.LayerBase exposing (CommonData)
import Scenes.$0.LayerSettings exposing (LayerT)


{-| Model
-}
type alias Model =
    LayerPacker CommonData LayerT
