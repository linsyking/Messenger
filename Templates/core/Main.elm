port module Main exposing (main)

{-| This is the doc for this module

@docs main

-}

import Audio exposing (AudioCmd, AudioData)
import Base exposing (..)
import Browser.Events exposing (onKeyDown, onKeyUp, onMouseDown, onMouseMove, onResize)
import Canvas
import Canvas.Settings exposing (fill)
import Color
import Common exposing (..)
import Dict
import Html exposing (Html)
import Html.Attributes exposing (style)
import Json.Decode as Decode
import Json.Encode as Encode
import Lib.Audio.Audio exposing (loadAudio, stopAudio)
import Lib.Coordinate.Coordinates exposing (fromMouseToReal, getStartPoint, maxHandW)
import Lib.Layer.Base exposing (LayerMsg(..))
import Lib.LocalStorage.LocalStorage exposing (decodeLSInfo, encodeLSInfo)
import Lib.Resources.Base exposing (allTexture, getTexture, saveSprite)
import Lib.Scene.Base exposing (..)
import Lib.Scene.SceneLoader exposing (getCurrentScene, loadSceneByName)
import MainConfig exposing (initScene, timeInterval)
import Scenes.SceneSettings exposing (..)
import Task
import Time


port audioPortToJS : Encode.Value -> Cmd msg


port sendInfo : String -> Cmd msg


port audioPortFromJS : (Decode.Value -> msg) -> Sub msg


port alert : String -> Cmd msg


{-| initModel
-}
initModel : Model
initModel =
    { currentData = NullSceneData
    , currentScene = nullSceneT
    , currentGlobalData = initGlobalData
    , time = 0
    , audiorepo = []
    }


{-| main

Main Function

-}
main : Program Flags (Audio.Model Msg Model) (Audio.Msg Msg)
main =
    Audio.elementWithAudio
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        , audio = audio
        , audioPort = { toJS = audioPortToJS, fromJS = audioPortFromJS }
        }


{-| init
-}
init : Flags -> ( Model, Cmd Msg, AudioCmd Msg )
init flags =
    let
        ms =
            loadSceneByName initModel initScene NullSceneMsg

        oldgd =
            ms.currentGlobalData

        ( gw, gh ) =
            maxHandW ( flags.windowWidth, flags.windowHeight )

        ( fl, ft ) =
            getStartPoint ( flags.windowWidth, flags.windowHeight )

        ls =
            decodeLSInfo flags.info

        -- Update volume in globaldata
        newgd =
            { oldgd | localstorage = ls, audioVolume = ls.volume, browserViewPort = ( flags.windowWidth, flags.windowHeight ), realWidth = gw, realHeight = gh, startLeft = fl, startTop = ft }
    in
    ( { ms | currentGlobalData = newgd }, Cmd.none, Audio.cmdNone )


normalUpdate : Msg -> Model -> ( Model, Cmd Msg, AudioCmd Msg )
normalUpdate msg model =
    if List.length (Dict.keys model.currentGlobalData.sprites) < List.length allTexture then
        -- Still loading assets
        ( model, Cmd.none, Audio.cmdNone )

    else
        let
            cs =
                getCurrentScene model

            cm =
                ( model.currentData, model.time )

            ( sdt, som, newgd ) =
                cs.update msg model.currentGlobalData cm

            tmodel =
                case msg of
                    Tick _ ->
                        { model | time = model.time + 1, currentGlobalData = newgd }

                    _ ->
                        { model | currentGlobalData = newgd }

            bnewmodel =
                { tmodel | currentData = sdt }

            ( newmodel, cmds, audiocmds ) =
                if List.isEmpty som then
                    ( updateSceneStartTime bnewmodel, [ sendInfo (encodeLSInfo tmodel.currentGlobalData.localstorage) ], [] )

                else
                    List.foldl
                        (\singleSOM ( lastModel, lastCmds, lastAudioCmds ) ->
                            case singleSOM of
                                SOMChangeScene ( tm, s ) ->
                                    --- Load new scene
                                    ( loadSceneByName lastModel s tm
                                        |> resetSceneStartTime
                                    , sendInfo (encodeLSInfo lastModel.currentGlobalData.localstorage) :: lastCmds
                                    , lastAudioCmds
                                    )

                                SOMPlayAudio name path opt ->
                                    ( lastModel, lastCmds, Audio.loadAudio (SoundLoaded name opt) path :: lastAudioCmds )

                                SOMSetVolume s ->
                                    let
                                        oldgd =
                                            lastModel.currentGlobalData

                                        newgd2 =
                                            { oldgd | audioVolume = s }
                                    in
                                    ( { lastModel | currentGlobalData = newgd2 }, lastCmds, lastAudioCmds )

                                SOMStopAudio name ->
                                    ( { lastModel | audiorepo = stopAudio lastModel.audiorepo name }, lastCmds, lastAudioCmds )
                        )
                        ( bnewmodel, [], [] )
                        som
        in
        ( newmodel, Cmd.batch cmds, Audio.cmdBatch audiocmds )


update : AudioData -> Msg -> Model -> ( Model, Cmd Msg, AudioCmd Msg )
update _ msg model =
    case msg of
        TextureLoaded name Nothing ->
            ( model, alert ("Failed to load sprite " ++ name), Audio.cmdNone )

        TextureLoaded name (Just t) ->
            let
                oldsprites =
                    model.currentGlobalData.sprites

                newsp =
                    saveSprite oldsprites name t

                oldgd =
                    model.currentGlobalData

                newgd =
                    { oldgd | sprites = newsp }
            in
            ( { model | currentGlobalData = newgd }, Cmd.none, Audio.cmdNone )

        SoundLoaded name opt result ->
            case result of
                Ok sound ->
                    ( model
                    , Task.perform (PlaySoundGotTime name opt sound) Time.now
                    , Audio.cmdNone
                    )

                Err _ ->
                    ( model
                    , alert ("Failed to load audio " ++ name)
                    , Audio.cmdNone
                    )

        PlaySoundGotTime name opt sound t ->
            ( { model | audiorepo = loadAudio model.audiorepo name sound opt t }, Cmd.none, Audio.cmdNone )

        NewWindowSize t ->
            let
                oldgd =
                    model.currentGlobalData

                ( gw, gh ) =
                    maxHandW t

                ( fl, ft ) =
                    getStartPoint t

                newgd =
                    { oldgd | browserViewPort = t, realWidth = gw, realHeight = gh, startLeft = fl, startTop = ft }
            in
            ( { model | currentGlobalData = newgd }, Cmd.none, Audio.cmdNone )

        MouseMove ( px, py ) ->
            let
                curgd =
                    model.currentGlobalData

                mp =
                    fromMouseToReal curgd ( toFloat px, toFloat py )
            in
            ( { model | currentGlobalData = { curgd | mousePos = mp } }, Cmd.none, Audio.cmdNone )

        _ ->
            normalUpdate msg model


{-| subscriptions
-}
subscriptions : AudioData -> Model -> Sub Msg
subscriptions _ _ =
    Sub.batch
        [ Time.every timeInterval Tick --- Slow down the fps
        , onKeyDown (Decode.map (\x -> KeyDown x) (Decode.field "keyCode" Decode.int))
        , onKeyUp (Decode.map (\x -> KeyUp x) (Decode.field "keyCode" Decode.int))
        , onResize (\w h -> NewWindowSize ( w, h ))
        , onMouseDown (Decode.map3 (\b x y -> MouseDown b ( x, y )) (Decode.field "button" Decode.int) (Decode.field "clientX" Decode.float) (Decode.field "clientY" Decode.float))
        , onMouseMove (Decode.map2 (\x y -> MouseMove ( x, y )) (Decode.field "clientX" Decode.int) (Decode.field "clientY" Decode.int))
        ]


{-| view
-}
view : AudioData -> Model -> Html Msg
view _ model =
    Canvas.toHtmlWith
        { width = model.currentGlobalData.realWidth
        , height = model.currentGlobalData.realHeight
        , textures = getTexture
        }
        [ style "left" (String.fromFloat model.currentGlobalData.startLeft)
        , style "top" (String.fromFloat model.currentGlobalData.startTop)
        , style "position" "fixed"
        ]
        [ Canvas.shapes [ fill Color.white ] [ Canvas.rect ( 0, 0 ) (toFloat model.currentGlobalData.realWidth) (toFloat model.currentGlobalData.realHeight) ]
        , (getCurrentScene model).view ( model.currentData, model.time ) model.currentGlobalData
        ]
