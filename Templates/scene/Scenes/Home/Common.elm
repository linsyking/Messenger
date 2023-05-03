module Scenes.Home.Common exposing (Model)

{-| This is the doc for this module

@docs Model

-}

import Lib.Scene.Base exposing (LayerPacker)
import Scenes.Home.LayerBase exposing (CommonData)
import Scenes.Home.LayerSettings exposing (LayerT)


{-| Model
-}
type alias Model =
    LayerPacker CommonData LayerT
