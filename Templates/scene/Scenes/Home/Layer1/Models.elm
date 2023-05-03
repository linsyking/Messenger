module Scenes.Home.Layer1.Models exposing
    ( initButton
    , initModel
    , updateModel
    )

{-| This is the doc for this module

@docs initButton

@docs initModel

@docs updateModel

-}

import Base exposing (..)
import Lib.Component.Base exposing (ComponentTMsg(..))
import Lib.Coordinate.Coordinates exposing (..)
import Lib.Layer.Base exposing (LayerMsg(..), LayerTarget(..))
import Lib.Scene.Base exposing (..)
import Scenes.Home.Layer1.Common exposing (..)
import Scenes.Home.LayerBase exposing (CommonData)


{-| initButton
-}
initButton : String -> Bool -> ( Int, Int ) -> Int -> Int -> Button
initButton description s ( x, y ) len wid =
    Button description s ( x, y ) len wid


{-| initModel
-}
initModel : Int -> LayerMsg -> CommonData -> Model
initModel _ _ _ =
    { start = initButton "Start" True ( 890, 920 ) 160 80
    , continue = initButton "Start" False ( 11890, 920 ) 160 80
    }


{-| updateModel
-}
updateModel : Msg -> GlobalData -> LayerMsg -> ( Model, Int ) -> CommonData -> ( ( Model, CommonData, List ( LayerTarget, LayerMsg ) ), GlobalData )
updateModel msg gd _ ( model, t ) cd =
    if cd.started then
        case msg of
            MouseDown 0 ( x, y ) ->
                if model.start.display && judgeMouse gd ( x, y ) ( Tuple.first model.start.pos, Tuple.second model.start.pos ) ( model.start.length, model.start.width ) then
                    ( ( model, cd, [ ( LayerName "Layer0", LayerIntMsg 0 ) ] ), gd )

                else if model.continue.display && judgeMouse gd ( x, y ) ( Tuple.first model.continue.pos, Tuple.second model.continue.pos ) ( model.continue.length, model.continue.width ) then
                    ( ( model, cd, [ ( LayerParentScene, LayerIntMsg 3 ) ] ), gd )

                else
                    ( ( model, cd, [] ), gd )

            _ ->
                ( ( model, cd, [] ), gd )

    else
        case msg of
            MouseDown 0 ( x, y ) ->
                if judgeMouse gd ( x, y ) ( 0, 0 ) ( 1920, 1080 ) then
                    ( ( model, { cd | started = True, presstime = t }, [ ( LayerParentScene, LayerIntMsg 2 ) ] ), gd )

                else
                    ( ( model, cd, [] ), gd )

            _ ->
                let
                    newstartbutton =
                        initButton "New Game" True ( 500, 920 ) 450 80

                    -- newcontinuebutton = initButton "Continue" True ( 1100, 920 ) 100 width
                    newcontinuebutton =
                        initButton "Continue" True ( 1100, 920 ) 350 80
                in
                ( ( { model | start = newstartbutton, continue = newcontinuebutton }, cd, [] ), gd )
