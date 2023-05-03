module Scenes.Home.Layer1.Common exposing
    ( Button
    , Model
    )

{-| This is the doc for this module

@docs Button

@docs ModelX

-}

import Base exposing (..)


{-| Button
-}
type alias Button =
    { description : String
    , display : Bool
    , pos : ( Int, Int )
    , length : Int
    , width : Int
    }


{-| ModelX
-}
type alias Model =
    { start : Button
    , continue : Button
    }
