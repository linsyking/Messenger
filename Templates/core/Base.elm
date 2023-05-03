module Base exposing
    ( Msg(..)
    , GlobalData
    , Flags
    , LSInfo
    )

{-| This is the doc for this module

WARNING: This file should have no dependencies

Otherwise it will cause import-cycles

I storage TMsg here that every scene can use it to transmit data, however, those data can only be Int, Float, Strong, etc.

This message is the GLOBAL scope message. This message limits what messsages you can get inside a scene.

@docs Msg

@docs GlobalData

@docs Flags

@docs LSInfo

-}

import Audio
import Canvas.Texture exposing (Texture)
import Dict exposing (Dict)
import Lib.Audio.Base exposing (AudioOption)
import Time


{-| Msg

This is the msg data for main.

`Tick` records the time.

`KeyDown`, `KeyUp` records the keyboard events

-}
type Msg
    = Tick Time.Posix
    | KeyDown Int
    | KeyUp Int
    | StringMessage String
    | NewWindowSize ( Int, Int )
    | SoundLoaded String AudioOption (Result Audio.LoadError Audio.Source)
    | PlaySoundGotTime String AudioOption Audio.Source Time.Posix
    | TextureLoaded String (Maybe Texture)
    | MouseDown Int ( Float, Float )
    | MouseMove ( Int, Int )
    | UnknownMsg


{-| GlobalData

GD is the data that doesn't change during the game.

It won't be reset if you change the scene.

It is mainly used for display and reading/writing some localstorage data.

`browserViewPort` records the browser size.

`sprites` records all the sprites(images).

`localstorage` records the data that we save in localstorage.

-}
type alias GlobalData =
    { browserViewPort : ( Int, Int )
    , realWidth : Int
    , realHeight : Int
    , startLeft : Float
    , startTop : Float
    , audioVolume : Float
    , sprites : Dict String Texture
    , scenesFinished : List String
    , scenestarttime : Int
    , mousePos : ( Float, Float )
    , localstorage : LSInfo
    }


{-| LSInfo

LocalStorage data

-}
type alias LSInfo =
    { volume : Float
    }


{-| Flags

The main flags.

Get info from js script

-}
type alias Flags =
    { windowWidth : Int
    , windowHeight : Int
    , info : String
    }



--- eg. Scene1 can export this type of message to other scenes
