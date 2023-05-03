module Lib.Layer.LayerHandler exposing
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
import Messenger.Recursion exposing (RecBody)
import Messenger.RecursionList exposing (updateObjects)


type alias Env a =
    { msg : Msg
    , globalData : GlobalData
    , t : Int
    , commonData : a
    }


type alias LayerT a b =
    ( String, Layer a b )


update : LayerT a b -> Env a -> LayerMsg -> ( LayerT a b, List ( LayerTarget, LayerMsg ), Env a )
update l env lm =
    let
        layer =
            Tuple.second l

        ( ( newData, newCD, nl ), newGD ) =
            layer.update env.msg env.globalData lm ( layer.data, env.t ) env.commonData
    in
    ( ( Tuple.first l, { layer | data = newData } ), nl, { env | globalData = newGD, commonData = newCD } )


match : LayerT a b -> LayerTarget -> Bool
match l t =
    case t of
        LayerParentScene ->
            False

        LayerName n ->
            n == Tuple.first l


super : LayerTarget -> Bool
super t =
    case t of
        LayerParentScene ->
            True

        LayerName _ ->
            False


recBody : RecBody (LayerT a b) LayerMsg (Env a) LayerTarget
recBody =
    { update = update, match = match, super = super }


updateLayerProto : Env a -> LayerMsg -> List (LayerT a b) -> ( List (LayerT a b), List LayerMsg, Env a )
updateLayerProto =
    updateObjects recBody


updateLayer : Msg -> GlobalData -> Int -> a -> List ( String, Layer a b ) -> ( ( List ( String, Layer a b ), a, List LayerMsg ), GlobalData )
updateLayer msg gd t cd xs =
    let
        env =
            { msg = msg, globalData = gd, t = t, commonData = cd }

        ( nl, nlm, nenv ) =
            updateLayerProto env NullLayerMsg xs
    in
    ( ( nl, nenv.commonData, nlm ), nenv.globalData )


{-| viewLayer

Get the view of the layer.

-}
viewLayer : GlobalData -> Int -> a -> List ( String, Layer a b ) -> Renderable
viewLayer vp t cd xs =
    Canvas.group []
        (List.map (\( _, l ) -> l.view ( l.data, t ) cd vp) xs)
