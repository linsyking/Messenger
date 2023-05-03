module Scenes.Home.Model exposing
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
import Scenes.Home.Common exposing (Model)
import Scenes.Home.Layer0.Export as L0
import Scenes.Home.Layer0.Global as L0G
import Scenes.Home.Layer1.Export as L1
import Scenes.Home.Layer1.Global as L1G
import Scenes.Home.LayerBase exposing (initCommonData)


{-| initModel
-}
initModel : Int -> SceneMsg -> Model
initModel t _ =
    { commonData = initCommonData
    , layers =
        [ ( "Layer0"
          , let
                x =
                    L0.layer
            in
            L0G.getLayerCT { x | data = L0.layer.init t NullLayerMsg initCommonData }
          )
        , ( "Layer1"
          , let
                x =
                    L1.layer
            in
            L1G.getLayerT { x | data = L1.layer.init t NullLayerMsg initCommonData }
          )
        ]
    }


{-| handleLayerMsg
-}
handleLayerMsg : GlobalData -> LayerMsg -> ( Model, Int ) -> ( Model, List SceneOutputMsg, GlobalData )
handleLayerMsg gd lmsg ( model, _ ) =
    case lmsg of
        LayerIntMsg 2 ->
            ( model, [ SOMPlayAudio "bgm" "assets/audio/music.mp3" ALoop ], gd )

        _ ->
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
