module Scenes.$0.Model exposing
    ( initModel
    , handleLayerMsg
    , updateModel
    , viewModel
    )

{-| This is the doc for this module

@docs initModel

@docs handleLayerMsg

@docs updateModel

@docs viewModel

-}

import Base exposing (GlobalData, Msg)
import Canvas exposing (Renderable)
import Lib.Audio.Base exposing (AudioOption(..))
import Lib.Layer.Base exposing (LayerMsg(..))
import Lib.Layer.LayerHandlerRaw exposing (updateLayer, viewLayer)
import Lib.Scene.Base exposing (SceneMsg(..), SceneOutputMsg(..))
import Scenes.$0.Common exposing (Model)
import Scenes.$0.LayerBase exposing (initCommonData)
$1


{-| initModel
-}
initModel : Int -> SceneMsg -> Model
initModel t _ =
    { commonData = initCommonData
    , layers =
        [
            $2
        ]
    }


{-| handleLayerMsg
-}
handleLayerMsg : GlobalData -> LayerMsg -> ( Model, Int ) -> ( Model, List SceneOutputMsg, GlobalData )
handleLayerMsg gd _ ( model, _ ) =
    ( model, [], gd )


{-| updateModel

Default update function

-}
updateModel : Msg -> GlobalData -> ( Model, Int ) -> ( Model, List SceneOutputMsg, GlobalData )
updateModel msg gd ( model, t ) =
    let
        ( ( newdata, newcd, msgs ), newgd ) =
            updateLayer msg gd t model.commonData model.layers

        nmodel =
            { model | commonData = newcd, layers = newdata }

        ( newmodel, newso, newwgd ) =
            List.foldl (\x ( y, _, cgd ) -> handleLayerMsg cgd x ( y, t )) ( nmodel, [], newgd ) msgs
    in
    ( newmodel, newso, newwgd )


{-| viewModel
Default view function
-}
viewModel : ( Model, Int ) -> GlobalData -> Renderable
viewModel ( model, t ) gd =
    viewLayer gd t model.commonData model.layers
