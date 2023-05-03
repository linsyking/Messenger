module Scenes.Home.Layer1.Display exposing (dview)

{-| This is the doc for this module

@docs dview

-}

import Base exposing (..)
import Canvas exposing (Renderable, group)
import Canvas.Settings.Advanced exposing (GlobalCompositeOperationMode(..), Shadow, shadow)
import Canvas.Settings.Text exposing (TextAlign(..))
import Color
import Lib.Coordinate.Coordinates exposing (..)
import Lib.Render.Render exposing (renderTextWithColor)
import Scenes.Home.Layer1.Common exposing (..)
import Scenes.Home.LayerBase exposing (CommonData)


{-| dview
-}
dview : ( Model, Int ) -> CommonData -> GlobalData -> Renderable
dview ( m, _ ) _ gd =
    group [ shadow (Shadow 4 Color.red ( 5, 5 )) ]
        [ renderButton m.start gd
        , renderButton m.continue gd
        ]


renderButton : Button -> GlobalData -> Renderable
renderButton b gd =
    if b.display then
        renderTextWithColor gd 80 b.description "Times New Roman" Color.black b.pos

    else
        group [] []
