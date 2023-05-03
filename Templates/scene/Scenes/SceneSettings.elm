module Scenes.SceneSettings exposing
    ( SceneDataTypes(..)
    , SceneT, nullSceneT
    )

{-| This is the doc for this module

@docs SceneDataTypes

@docs SceneCT

@docs nullSceneCT

-}

import Base exposing (..)
import Canvas exposing (group)
import Lib.Scene.Base exposing (..)
$0



--- Set Scenes


{-| SceneDataTypes

All the scene data types should be listed here.

-}
type SceneDataTypes
    = $1
    | NullSceneData


{-| SceneCT

SceneCT is a Scene with datatypes.

-}
type alias SceneT =
    Scene SceneDataTypes


{-| nullSceneCT
-}
nullSceneT : SceneT
nullSceneT =
    { init = \_ _ -> NullSceneData
    , update = \_ g ( _, _ ) -> ( NullSceneData, [], g )
    , view = \_ _ -> group [] []
    }
