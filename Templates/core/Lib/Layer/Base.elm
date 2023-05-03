module Lib.Layer.Base exposing
    ( LayerMsg(..)
    , LayerTarget(..)
    , Layer
    )

{-| This is the doc for this module

Layer plays a very important role in the game framework.

It is mainly used to seperate different rendering layers.

Using layers can help us deal with different things in different layers.

@docs LayerMsg

@docs LayerTarget

@docs Layer

-}

import Base exposing (GlobalData, Msg)
import Canvas exposing (Renderable)
import Lib.Audio.Base exposing (AudioOption)


{-| Layer

Layer data type.

b is the layer data, a is the common data that shares between layers

-}
type alias Layer a b =
    { data : b
    , init : Int -> LayerMsg -> a -> b
    , update : Msg -> GlobalData -> LayerMsg -> ( b, Int ) -> a -> ( ( b, a, List ( LayerTarget, LayerMsg ) ), GlobalData )
    , view : ( b, Int ) -> a -> GlobalData -> Renderable
    }


{-| LayerMsg

Add your own layer messages here.

-}
type LayerMsg
    = LayerStringMsg String
    | LayerIntMsg Int
    | LayerSoundMsg String String AudioOption
    | LayerStopSoundMsg String
    | NullLayerMsg


{-| LayerTarget

You can send message to a layer by using LayerTarget.

LayerParentScene is used to send message to the parent scene of the layer.

LayerName is used to send message to a specific layer.

-}
type LayerTarget
    = LayerParentScene
    | LayerName String
