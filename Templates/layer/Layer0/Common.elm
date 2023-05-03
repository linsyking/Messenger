module Scenes.Home.Layer0.Common exposing (Model)

{-| This is the doc for this module

@docs ModelX

@docs SModel

-}

import Array exposing (Array)
import Base exposing (..)
import Lib.Component.Base exposing (Component)


{-| ModelX
-}
type alias Model =
    { components : Array Component
    }
