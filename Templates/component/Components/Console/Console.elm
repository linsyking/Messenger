module Components.Console.Console exposing
    ( initModel
    , updateModel
    , viewModel
    )

{-| This is the doc for this module

@docs initModel

@docs updateModel

@docs viewModel

-}

import Base exposing (GlobalData, Msg(..))
import Canvas exposing (Renderable, group, rect, shapes)
import Canvas.Settings.Advanced exposing (alpha)
import Char exposing (fromCode)
import Dict
import Lib.Component.Base exposing (ComponentTMsg(..), ComponentTarget(..), Data, DefinedTypes(..))
import Lib.Coordinate.Coordinates exposing (heightToReal, posToReal, widthToReal)
import Lib.DefinedTypes.Parser exposing (dBoolGet, dBoolSet, dStringGet, dStringSet)
import Lib.Render.Render exposing (renderText)


{-| initModel
-}
initModel : Int -> Int -> ComponentTMsg -> Data
initModel _ id _ =
    Dict.fromList
        [ ( "input", CDString "" )
        , ( "state", CDBool False )
        , ( "id", CDInt id )
        ]


{-| updateModel
-}
updateModel : Msg -> GlobalData -> ComponentTMsg -> ( Data, Int ) -> ( Data, List ( ComponentTarget, ComponentTMsg ), GlobalData )
updateModel msg gd _ ( d, _ ) =
    let
        command =
            dStringGet d "input"

        state =
            dBoolGet d "state"
    in
    case msg of
        KeyDown 192 ->
            if state then
                ( d |> dBoolSet "state" (not state), [ ( ComponentParentLayer, ComponentStringMsg "startGameInput" ) ], gd )

            else
                ( d |> dBoolSet "state" (not state), [ ( ComponentParentLayer, ComponentStringMsg "stopGameInput" ) ], gd )

        KeyDown 8 ->
            if state then
                ( d |> dStringSet "input" (String.dropRight 1 command), [], gd )

            else
                ( d, [], gd )

        KeyDown 13 ->
            if state then
                ( d
                    |> dStringSet "input" ""
                    |> dBoolSet "state" False
                , [ ( ComponentParentLayer, sendmsg command ), ( ComponentParentLayer, ComponentStringMsg "startGameInput" ) ]
                , gd
                )

            else
                ( d, [], gd )

        KeyDown x ->
            if state then
                ( d |> dStringSet "input" (String.append command (String.fromChar (Char.toLower (fromCode x)))), [], gd )

            else
                ( d, [], gd )

        _ ->
            ( d, [], gd )


{-| sendmsg
-}
sendmsg : String -> ComponentTMsg
sendmsg command =
    let
        loadscene =
            String.left 5 command == "load "

        cheatenergy =
            String.left 5 command == "gete "
    in
    if loadscene then
        let
            scenename =
                String.dropLeft 5 command

            ld =
                String.dropLeft 1 scenename

            realname =
                String.left 1 (String.toUpper scenename)

            kk =
                String.concat [ realname, ld ]
        in
        ComponentLStringMsg [ "nextscene", kk ]

    else if cheatenergy then
        let
            energy =
                String.dropLeft 5 command
        in
        ComponentStringIntMsg "addenergy" (Maybe.withDefault 0 (String.toInt energy))

    else
        NullComponentMsg


{-| viewModel
-}
viewModel : ( Data, Int ) -> GlobalData -> Renderable
viewModel ( d, t ) gd =
    let
        command =
            dStringGet d "input"

        state =
            dBoolGet d "state"
    in
    if state then
        group []
            [ shapes [ alpha 0.1 ] [ rect (posToReal gd ( 20, 970 )) (widthToReal gd 1850) (heightToReal gd 40) ]
            , renderText gd 30 ("> " ++ command ++ "_") "sans-seif" ( 30, 975 )
            ]

    else
        group [] []
