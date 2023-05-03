module Scenes.Home.Layer0.Models exposing
    ( initModel
    , updateModel
    )

{-| This is the doc for this module

@docs initModel

@docs updateModel

-}

import Array
import Base exposing (..)
import Components.A.Export as A
import Components.B.Export as B
import Components.Console.Export as Console
import Lib.Audio.Base exposing (AudioOption(..))
import Lib.Component.Base exposing (ComponentTMsg(..))
import Lib.Component.ComponentHandler exposing (updateComponents)
import Lib.Layer.Base exposing (LayerMsg(..), LayerTarget(..))
import Lib.Scene.Base exposing (..)
import Scenes.Home.Layer0.Common exposing (..)
import Scenes.Home.LayerBase exposing (CommonData)


{-| initModel
-}
initModel : Int -> LayerMsg -> CommonData -> Model
initModel _ _ _ =
    { components =
        Array.fromList
            [ Console.initComponent 0 0 NullComponentMsg
            , A.initComponent 0 1 NullComponentMsg
            , B.initComponent 0 2 NullComponentMsg
            ]
    }


{-| updateModel
-}
updateModel : Msg -> GlobalData -> LayerMsg -> ( Model, Int ) -> CommonData -> ( ( Model, CommonData, List ( LayerTarget, LayerMsg ) ), GlobalData )
updateModel msg gd _ ( model, t ) cd =
    let
        components =
            model.components

        ( newComponents, resp, newGlobalData ) =
            updateComponents msg gd t components

        test =
            if List.isEmpty resp then
                []

            else
                Debug.log "Layer result" resp
    in
    ( ( { model | components = newComponents }, cd, [] ), newGlobalData )
