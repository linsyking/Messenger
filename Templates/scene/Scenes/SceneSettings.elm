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
import Scenes.Home.Export as H



--- Set Scenes


{-| SceneDataTypes

All the scene data types should be listed here.

`HdataT` is for Home Scene.

`CoreEngineDataT` is for the Core Engine Scene.

-}
type SceneDataTypes
    = HomeDataT H.Data
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
