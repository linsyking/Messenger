module Scenes.Home.Layer0.Display exposing (dview)

{-| This is the doc for this module

@docs dview

-}

import Base exposing (..)
import Canvas exposing (Renderable, group)
import Canvas.Settings.Advanced exposing (GlobalCompositeOperationMode(..))
import Canvas.Settings.Text exposing (TextAlign(..))
import Lib.Component.ComponentHandler exposing (viewComponent)
import Lib.Coordinate.Coordinates exposing (..)
import Lib.Render.Render exposing (renderSprite, renderText)
import Scenes.Home.Layer0.Common exposing (..)
import Scenes.Home.LayerBase exposing (CommonData)


{-| dview
-}
dview : ( Model, Int ) -> CommonData -> GlobalData -> Renderable
dview ( model, t ) _ gd =
    group []
        [ renderSprite gd [] ( 0, 0 ) ( 1920, 1080 ) "ball"
        , renderText gd 30 "Ver. 1.0.0" "Courier New" ( 1700, 1000 )
        , viewComponent gd 0 model.components
        ]
