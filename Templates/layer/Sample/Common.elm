module Scenes.$0.Common exposing (Model)

{-| This is the doc for this module

@docs Model

-}

import Array exposing (Array)
import Base exposing (..)
import Lib.Component.Base exposing (Component)


{-| Model
-}
type alias Model =
    { components : Array Component
    }
