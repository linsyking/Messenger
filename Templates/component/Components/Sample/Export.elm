module Components.$0.Export exposing
    ( component
    , initComponent
    )

{-| This is the doc for this module

Console is a tool to load levels and enter commands.

@docs component

@docs initComponent

-}

import Components.$0.$0 exposing (initModel, updateModel, viewModel)
import Lib.Component.Base exposing (Component, ComponentTMsg(..))


{-| component
-}
component : Component
component =
    { name = "$0"
    , data = initModel 0 0 NullComponentMsg
    , init = initModel
    , update = updateModel
    , view = viewModel
    }


{-| initComponent
t is the initial time for this component.

You need to pass a ComponentIntMsg for its id.

-}
initComponent : Int -> Int -> ComponentTMsg -> Component
initComponent t id ct =
    { component | data = component.init t id ct }
