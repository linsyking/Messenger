module Lib.Scene.Base exposing
    ( SceneMsg(..)
    , SceneOutputMsg(..)
    , Scene
    , nullScene
    , LayerPacker
    )

{-| This is the doc for this module


# Scene

Scene plays an important role in our game engine.

It is like a "page". You can change scenes in the game.

Different levels are different scenes.

You have to transmit data to next scene if you don't store the data in globaldata.

@docs SceneMsg

@docs SceneOutputMsg

@docs Scene

@docs nullScene

-}

import Base exposing (GlobalData, Msg)
import Canvas exposing (Renderable, group)
import Lib.Audio.Base exposing (AudioOption)


{-| Scene
-}
type alias Scene a =
    { init : Int -> SceneMsg -> a
    , update : Msg -> GlobalData -> ( a, Int ) -> ( a, List SceneOutputMsg, GlobalData )
    , view : ( a, Int ) -> GlobalData -> Renderable
    }


{-| nullScene
-}
nullScene : Scene Bool
nullScene =
    { init = \_ _ -> True
    , update = \_ gd ( x, _ ) -> ( x, [], gd )
    , view = \_ _ -> group [] []
    }


{-| SceneMsg

The `SceneEngineMsg` is used to initialize the game engine.

-}
type SceneMsg
    = SceneStringMsg String
    | SceneIntMsg Int
    | NullSceneMsg


{-| SceneOutputMsg

When you want to change the scene or play the audio, you have to send those messages to the central controller.

-}
type SceneOutputMsg
    = SOMChangeScene ( SceneMsg, String )
    | SOMPlayAudio String String AudioOption
    | SOMStopAudio String
    | SOMSetVolume Float


type alias LayerPacker a b =
    { commonData : a
    , layers : List ( String, b )
    }
