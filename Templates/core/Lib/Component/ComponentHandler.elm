module Lib.Component.ComponentHandler exposing
    ( updateComponents
    , getComponent
    , getComponentIdxById, getComponentIdxByName, updateOnceComponentByComponent, updateOnceComponentById, updateOnceComponentByIdx, updateOnceComponents, updateOnceComponentsByName, viewComponent
    )

{-| ComponentHandler deals with components

@docs updateComponents

@docs updateOneComponent

@docs updateSingleComponent

@docs updateSingleComponentByName

@docs getComponent

@docs getComponentFromName

@docs queryComponent

-}

import Array exposing (Array)
import Base exposing (GlobalData, Msg)
import Canvas exposing (Renderable)
import Dict
import Lib.Component.Base exposing (Component, ComponentTMsg(..), ComponentTarget(..), DefinedTypes(..))
import Lib.Tools.Array exposing (locate)
import Messenger.Recursion exposing (RecBody)
import Messenger.RecursionArray exposing (updateObjects)


{-| updateComponents
-}
updateOnceComponents : Int -> Msg -> GlobalData -> Array Component -> ( Array Component, List ( ComponentTarget, ComponentTMsg ), GlobalData )
updateOnceComponents t msg gd xs =
    Array.foldl
        (\x ( acs, ct, mlgg ) ->
            let
                ( newx, newmsg, newgd ) =
                    x.update msg mlgg NullComponentMsg ( x.data, t )
            in
            ( Array.push { x | data = newx } acs, ct ++ newmsg, newgd )
        )
        ( Array.empty, [], gd )
        xs


{-| updateOneComponent
Given the component, we update it.
-}
updateOnceComponentByComponent : Msg -> ComponentTMsg -> GlobalData -> Int -> Component -> ( Component, List ( ComponentTarget, ComponentTMsg ), GlobalData )
updateOnceComponentByComponent msg ct gd t c =
    let
        ( newx, newmsg, newgd ) =
            c.update msg gd ct ( c.data, t )
    in
    ( { c | data = newx }, newmsg, newgd )


{-| updateSingleComponent

Given an index and an array of components, update that component.

-}
updateOnceComponentByIdx : Msg -> ComponentTMsg -> GlobalData -> Int -> Int -> Array Component -> ( Array Component, List ( ComponentTarget, ComponentTMsg ), GlobalData )
updateOnceComponentByIdx msg ct gd t n xs =
    case getComponent n xs of
        Just k ->
            let
                ( newx, newmsg, newgd ) =
                    k.update msg gd ct ( k.data, t )
            in
            ( Array.set n { k | data = newx } xs, newmsg, newgd )

        Nothing ->
            ( xs, [], gd )


{-| updateOnceComponentsByName

Update all components with the given name.

-}
updateOnceComponentsByName : Msg -> ComponentTMsg -> GlobalData -> Int -> String -> Array Component -> ( Array Component, List ( ComponentTarget, ComponentTMsg ), GlobalData )
updateOnceComponentsByName msg ct gd t s xs =
    let
        ns =
            getComponentIdxByName s xs
    in
    List.foldl
        (\n ( lastxs, lastmsg, lastgd ) ->
            case getComponent n lastxs of
                Just k ->
                    let
                        ( newx, newmsg, newgd ) =
                            k.update msg lastgd ct ( k.data, t )
                    in
                    ( Array.set n { k | data = newx } lastxs, newmsg ++ lastmsg, newgd )

                Nothing ->
                    ( lastxs, lastmsg, lastgd )
        )
        ( xs, [], gd )
        ns



{-
   Update a component by its id
-}


updateOnceComponentById : Msg -> ComponentTMsg -> GlobalData -> Int -> Int -> Array Component -> ( Array Component, List ( ComponentTarget, ComponentTMsg ), GlobalData )
updateOnceComponentById msg ct gd t id xs =
    let
        n =
            getComponentIdxById id xs
    in
    case getComponent n xs of
        Just k ->
            let
                ( newx, newmsg, newgd ) =
                    k.update msg gd ct ( k.data, t )
            in
            ( Array.set n { k | data = newx } xs, newmsg, newgd )

        Nothing ->
            ( xs, [], gd )


{-| Generate the view of the components
-}
viewComponent : GlobalData -> Int -> Array Component -> Renderable
viewComponent vp t xs =
    Canvas.group [] (Array.toList (Array.map (\x -> x.view ( x.data, t ) vp) xs))


{-| getComponent
-}
getComponent : Int -> Array Component -> Maybe Component
getComponent n xs =
    Array.get n xs


{-| getComponentFromName
-}
getComponentIdxByName : String -> Array Component -> List Int
getComponentIdxByName s xs =
    locate (\x -> x.name == s) xs


{-| Get the index of a component by its id
-}
getComponentIdxById : Int -> Array Component -> Int
getComponentIdxById id xs =
    Maybe.withDefault -1 (List.head (locate (\x -> Dict.get "id" x.data == Just (CDInt id)) xs))


type alias Env =
    { msg : Msg
    , globalData : GlobalData
    , t : Int
    }


update : Component -> Env -> ComponentTMsg -> ( Component, List ( ComponentTarget, ComponentTMsg ), Env )
update c env ct =
    let
        ( newx, newmsg, newgd ) =
            c.update env.msg env.globalData ct ( c.data, env.t )
    in
    ( { c | data = newx }, newmsg, { env | globalData = newgd } )


match : Component -> ComponentTarget -> Bool
match c ct =
    case ct of
        ComponentParentLayer ->
            False

        ComponentByID x ->
            Dict.get "id" c.data == Just (CDInt x)

        ComponentByName x ->
            c.name == x


super : ComponentTarget -> Bool
super ct =
    case ct of
        ComponentParentLayer ->
            True

        _ ->
            False


recBody : RecBody Component ComponentTMsg Env ComponentTarget
recBody =
    { update = update
    , match = match
    , super = super
    }


updateComponentsProto : Env -> ComponentTMsg -> Array Component -> ( Array Component, List ComponentTMsg, Env )
updateComponentsProto =
    updateObjects recBody


updateComponents : Msg -> GlobalData -> Int -> Array Component -> ( Array Component, List ComponentTMsg, GlobalData )
updateComponents msg gd t cs =
    let
        ( ac, ct, env ) =
            updateComponentsProto { msg = msg, globalData = gd, t = t } NullComponentMsg cs
    in
    ( ac, ct, env.globalData )
