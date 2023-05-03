module Scenes.Home.Global exposing
    ( dataToSDT
    , sceneToST
    , sdtToData
    )

{-| This is the doc for this module

@docs sdata

@docs dtToT

@docs toCT

-}

import Base exposing (GlobalData, Msg)
import Canvas exposing (Renderable)
import Lib.Scene.Base exposing (..)
import Scenes.Home.Export exposing (..)
import Scenes.SceneSettings exposing (..)


{-| sdata
-}
dataToSDT : Data -> SceneDataTypes
dataToSDT d =
    HomeDataT d


{-| dtToT
-}
sdtToData : SceneDataTypes -> Data
sdtToData dt =
    case dt of
        HomeDataT x ->
            x

        _ ->
            nullData


{-| toCT
-}
sceneToST : Scene Data -> SceneT
sceneToST sd =
    let
        init : Int -> SceneMsg -> SceneDataTypes
        init t tm =
            dataToSDT (sd.init t tm)

        update : Msg -> GlobalData -> ( SceneDataTypes, Int ) -> ( SceneDataTypes, List SceneOutputMsg, GlobalData )
        update msg gd ( dt, t ) =
            let
                ( sdt, som, newgd ) =
                    sd.update msg gd ( sdtToData dt, t )
            in
            ( dataToSDT sdt, som, newgd )

        view : ( SceneDataTypes, Int ) -> GlobalData -> Renderable
        view ( dt, t ) vp =
            sd.view ( sdtToData dt, t ) vp
    in
    { init = init
    , update = update
    , view = view
    }
