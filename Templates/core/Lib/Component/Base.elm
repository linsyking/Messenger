module Lib.Component.Base exposing
    ( ComponentTMsg(..)
    , DefinedTypes(..)
    , Component
    , Data
    , nullComponent
    , ComponentTarget(..)
    )

{-|


# Component

Component is designed to have the best flexibility and compability.

You can use component almost anywhere, in layers, in gamecomponents and components themselves.

You have to manually add components in your layer and update them manually.

It is **not** fast to communicate between many components.

Gamecomponents have better speed when communicating with each other. (their message types are built-in)

@docs ComponentTMsg

@docs DefinedTypes

@docs Component

@docs Data

@docs nullComponent

-}

import Base exposing (GlobalData, Msg)
import Canvas exposing (Renderable, group)
import Dict exposing (Dict)



--- Component Base


{-| Component
-}
type alias Component =
    { name : String
    , data : Data
    , init : Int -> Int -> ComponentTMsg -> Data
    , update : Msg -> GlobalData -> ComponentTMsg -> ( Data, Int ) -> ( Data, List ( ComponentTarget, ComponentTMsg ), GlobalData )
    , view : ( Data, Int ) -> GlobalData -> Renderable
    }


{-| nullComponent
-}
nullComponent : Component
nullComponent =
    { name = "NULL"
    , data = Dict.empty
    , init = \_ _ _ -> Dict.empty
    , update =
        \_ gd _ _ ->
            ( Dict.empty
            , []
            , gd
            )
    , view = \_ _ -> group [] []
    }


{-| ComponentTMsg

This is the message that can be sent to the layer

Those entries are some basic data types we need.

-}
type ComponentTMsg
    = ComponentStringMsg String
    | ComponentIntMsg Int
    | ComponentLStringMsg (List String)
    | ComponentLSStringMsg String (List String)
    | ComponentStringDictMsg String Data
    | ComponentStringIntMsg String Int
    | NullComponentMsg


type ComponentTarget
    = ComponentParentLayer
    | ComponentByName String
    | ComponentByID Int


{-| Data
-}
type alias Data =
    Dict String DefinedTypes


{-| DefinedTypes

Defined type is used to store more data types in components.

Those entries are the commonly used data types.

Note that you can use `CDComponent` to store components inside components.

-}
type DefinedTypes
    = CDInt Int
    | CDBool Bool
    | CDFloat Float
    | CDString String
    | CDComponent Component
    | CDListDT (List DefinedTypes)
    | CDDictDT (Dict String DefinedTypes)
