module Components.A.Export exposing
    ( component
    , initComponent
    )

{-| This is the doc for this module

Console is a tool to load levels and enter commands.

@docs component

@docs initComponent

-}

import Canvas exposing (group)
import Components.A.A exposing (initModel, updateModel)
import Lib.Component.Base exposing (Component, ComponentTMsg(..))


{-| component
name : Component Type
data : the model for Console
init : the init function for Console
update : the update function for Console
view : the view function for Console
query : Console does not require query function
-}
component : Component
component =
    { name = "A"
    , data = initModel 0 0 NullComponentMsg
    , init = initModel
    , update = updateModel
    , view = \_ _ -> group [] []
    }


{-| initComponent
t is the initial time for this component.

You need to pass a ComponentIntMsg for its id.

-}
initComponent : Int -> Int -> ComponentTMsg -> Component
initComponent t id ct =
    { component | data = component.init t id ct }
