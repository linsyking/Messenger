module Scenes.$0.$1.Model exposing
    ( initModel
    , updateModel
    , viewModel
    )

{-| This is the doc for this module

@docs initModel

@docs updateModel

-}

import Array
import Base exposing (..)
import Canvas exposing (Renderable)
import Lib.Component.Base exposing (ComponentTMsg(..))
import Lib.Component.ComponentHandler exposing (updateComponents, viewComponent)
import Lib.Layer.Base exposing (LayerMsg(..), LayerTarget(..))
import Lib.Scene.Base exposing (..)
import Scenes.$0.$1.Common exposing (..)
import Scenes.$0.LayerBase exposing (CommonData)


{-| initModel
Add components here
-}
initModel : Int -> LayerMsg -> CommonData -> Model
initModel _ _ _ =
    { components = Array.empty
    }


{-| updateModel
Default update function
-}
updateModel : Msg -> GlobalData -> LayerMsg -> ( Model, Int ) -> CommonData -> ( ( Model, CommonData, List ( LayerTarget, LayerMsg ) ), GlobalData )
updateModel msg gd _ ( model, t ) cd =
    let
        components =
            model.components

        ( newComponents, _, newGlobalData ) =
            updateComponents msg gd t components
    in
    ( ( { model | components = newComponents }, cd, [] ), newGlobalData )


{-| viewModel
Default view function
-}
viewModel : ( Model, Int ) -> CommonData -> GlobalData -> Renderable
viewModel ( model, t ) _ gd =
    viewComponent gd t model.components
