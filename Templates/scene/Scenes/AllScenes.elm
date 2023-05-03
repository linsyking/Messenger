module Scenes.AllScenes exposing (allScenes)

{-| This is the doc for this module

This module records all the scenes.

@docs allScenes

-}

import Scenes.Home.Export as H
import Scenes.Home.Global as HG
import Scenes.SceneSettings exposing (..)


{-| allScenes
Add all the scenes here
-}
allScenes : List ( String, SceneT )
allScenes =
    [ ( "Home", HG.sceneToST H.scene )
    ]
