module Scenes.Home.LayerBase exposing
    ( CommonData
    , initCommonData
    )

{-| This is the doc for this module

@docs CommonData

-}


{-| CommonData
-}
type alias CommonData =
    { started : Bool
    , presstime : Int
    }


initCommonData : CommonData
initCommonData =
    { started = False
    , presstime = 0
    }
