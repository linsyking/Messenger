module Lib.Layer.LayerHandlerRaw exposing
    ( updateLayer
    , viewLayer
    )

{-|


# Layer Handler

@docs updateLayer

@docs viewLayer

-}

import Base exposing (GlobalData, Msg)
import Canvas exposing (Renderable)
import Lib.Layer.Base exposing (Layer, LayerMsg(..), LayerTarget(..))


{-| getLayerMsg

Get the layer message from the list of layer messages, indexed by the layer name.

-}
getLayerMsg : List ( LayerTarget, LayerMsg ) -> String -> List LayerMsg
getLayerMsg xs s =
    let
        ref =
            List.filter
                (\( x, _ ) ->
                    case x of
                        LayerName ln ->
                            if ln == s then
                                True

                            else
                                False

                        _ ->
                            False
                )
                xs
    in
    List.map (\( _, x ) -> x) ref


{-| applyOnce
-}
applyOnce : Msg -> GlobalData -> Int -> a -> List ( LayerTarget, LayerMsg ) -> List ( LayerTarget, LayerMsg ) -> List ( String, Layer a b ) -> List ( String, Layer a b ) -> ( ( List ( LayerTarget, LayerMsg ), List ( String, Layer a b ), a ), GlobalData )
applyOnce msg gd t cd lms ms dxs xs =
    case xs of
        [] ->
            ( ( lms, dxs, cd ), gd )

        ( name, layer ) :: lxs ->
            let
                data =
                    layer.data

                slname =
                    getLayerMsg ms name

                ( ( newdata, newcd, newmsg ), newgd ) =
                    if List.isEmpty slname then
                        let
                            ( ( xxx, yyy, lltlm ), zgd ) =
                                layer.update msg gd NullLayerMsg ( data, t ) cd
                        in
                        ( ( xxx, yyy, lltlm ), zgd )

                    else
                        List.foldl
                            (\x ( ( dd, dcd, dmg ), nngd ) ->
                                let
                                    ( ( xxx, yyy, lltlm ), zgd ) =
                                        layer.update msg nngd x ( dd, t ) dcd
                                in
                                ( ( xxx, yyy, dmg ++ lltlm ), zgd )
                            )
                            ( ( data, cd, [] ), gd )
                            slname
            in
            applyOnce msg newgd t newcd (lms ++ newmsg) ms (dxs ++ [ ( name, { layer | data = newdata } ) ]) lxs


{-| applyOnceOnlyNew
-}
applyOnceOnlyNew : Msg -> GlobalData -> Int -> a -> List ( LayerTarget, LayerMsg ) -> List ( LayerTarget, LayerMsg ) -> List ( String, Layer a b ) -> List ( String, Layer a b ) -> ( ( List ( LayerTarget, LayerMsg ), List ( String, Layer a b ), a ), GlobalData )
applyOnceOnlyNew msg gd t cd lms ms dxs xs =
    case xs of
        [] ->
            ( ( lms, dxs, cd ), gd )

        ( name, layer ) :: lxs ->
            let
                data =
                    layer.data

                slname =
                    getLayerMsg ms name

                ( ( newdata, newcd, newmsg ), newgd ) =
                    if List.isEmpty slname then
                        ( ( data, cd, [] ), gd )

                    else
                        List.foldl
                            (\x ( ( dd, dcd, dmg ), nngd ) ->
                                let
                                    ( ( xxx, yyy, lltlm ), zgd ) =
                                        layer.update msg nngd x ( dd, t ) dcd
                                in
                                ( ( xxx, yyy, dmg ++ lltlm ), zgd )
                            )
                            ( ( data, cd, [] ), gd )
                            slname
            in
            applyOnceOnlyNew msg newgd t newcd (lms ++ newmsg) ms (dxs ++ [ ( name, { layer | data = newdata } ) ]) lxs


{-| updateOnce
-}
updateOnce : Msg -> GlobalData -> Int -> a -> List ( LayerTarget, LayerMsg ) -> List ( String, Layer a b ) -> ( ( List ( LayerTarget, LayerMsg ), List ( String, Layer a b ), a ), GlobalData )
updateOnce msg gd t cd msgs xs =
    applyOnce msg gd t cd [] msgs [] xs


{-| updateOnceOnlyNew
-}
updateOnceOnlyNew : Msg -> GlobalData -> Int -> a -> List ( LayerTarget, LayerMsg ) -> List ( String, Layer a b ) -> ( ( List ( LayerTarget, LayerMsg ), List ( String, Layer a b ), a ), GlobalData )
updateOnceOnlyNew msg gd t cd msgs xs =
    applyOnceOnlyNew msg gd t cd [] msgs [] xs



--- msg, t, ms and xs doesn't change


{-| updateLayer
-}
updateLayer : Msg -> GlobalData -> Int -> a -> List ( String, Layer a b ) -> ( ( List ( String, Layer a b ), a, List LayerMsg ), GlobalData )
updateLayer msg gd t cd xs =
    let
        ( ( fmsg, fdata, fcd ), newgd ) =
            updateOnce msg gd t cd [] xs
    in
    updateLayerRecursive msg newgd t fcd fmsg fdata


{-| judgeEnd
-}
judgeEnd : List ( LayerTarget, LayerMsg ) -> Bool
judgeEnd xs =
    List.all
        (\( x, _ ) ->
            case x of
                LayerParentScene ->
                    True

                _ ->
                    False
        )
        xs


{-| filterLayerParentMsg
-}
filterLayerParentMsg : List ( LayerTarget, LayerMsg ) -> List ( LayerTarget, LayerMsg )
filterLayerParentMsg xs =
    List.filter
        (\( x, _ ) ->
            case x of
                LayerParentScene ->
                    True

                _ ->
                    False
        )
        xs


{-| filterLayerParentMsgT
-}
filterLayerParentMsgT : List ( LayerTarget, LayerMsg ) -> List LayerMsg
filterLayerParentMsgT xs =
    let
        css =
            List.filter
                (\( x, _ ) ->
                    case x of
                        LayerParentScene ->
                            True

                        _ ->
                            False
                )
                xs
    in
    List.map (\( _, x ) -> x) css


{-| updateLayerRecursive
-}
updateLayerRecursive : Msg -> GlobalData -> Int -> a -> List ( LayerTarget, LayerMsg ) -> List ( String, Layer a b ) -> ( ( List ( String, Layer a b ), a, List LayerMsg ), GlobalData )
updateLayerRecursive msg gd t cd msgs xs =
    if judgeEnd msgs then
        ( ( xs, cd, filterLayerParentMsgT msgs ), gd )

    else
        --- Update once
        let
            ( ( newmsgs, newdata, newcd ), newgd ) =
                updateOnceOnlyNew msg gd t cd msgs xs

            tmsgs =
                filterLayerParentMsg msgs
        in
        updateLayerRecursive msg newgd t newcd (newmsgs ++ tmsgs) newdata


{-| viewLayer

Get the view of the layer.

-}
viewLayer : GlobalData -> Int -> a -> List ( String, Layer a b ) -> Renderable
viewLayer vp t cd xs =
    Canvas.group []
        (List.map (\( _, l ) -> l.view ( l.data, t ) cd vp) xs)
