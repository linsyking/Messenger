module Lib.Scene.SceneLoader exposing
    ( getScene
    , loadScene
    , loadSceneByName
    , getCurrentScene
    )

{-| This is the doc for this module

@docs getScene

@docs loadScene

@docs loadSceneByName

@docs getCurrentScene

-}

import Common exposing (..)
import Lib.Scene.Base exposing (SceneMsg)
import List exposing (head)
import Scenes.AllScenes exposing (allScenes)
import Scenes.SceneSettings exposing (..)



-- import Scenes.Scene1.Export exposing (Scene1DataT)


{-| getScene
-}
getScene : String -> SceneT
getScene i =
    let
        scenes =
            allScenes

        tests =
            List.filter (\( x, _ ) -> x == i) scenes

        head =
            List.head tests
    in
    case head of
        Just ( _, x ) ->
            x

        Nothing ->
            nullSceneT


{-| loadScene
-}
loadScene : Model -> SceneT -> SceneMsg -> Model
loadScene model cs tm =
    let
        ls =
            { model | currentScene = cs }

        ld =
            { ls | currentData = cs.init ls.time tm }
    in
    ld


{-| loadSceneByName
-}
loadSceneByName : Model -> String -> SceneMsg -> Model
loadSceneByName model i tm =
    let
        sc =
            getScene i
    in
    loadScene model sc tm


{-| getCurrentScene
-}
getCurrentScene : Model -> SceneT
getCurrentScene model =
    model.currentScene
