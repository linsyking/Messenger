module Scenes.$0.LayerBase exposing
    ( CommonData
    , initCommonData
    )

{-| This is the doc for this module

@docs CommonData

@docs initCommonData

-}


{-| CommonData

Edit your own CommonData here!

-}
type alias CommonData =
    { started : Bool
    , presstime : Int
    }


{-| Init CommonData
-}
initCommonData : CommonData
initCommonData =
    { started = False
    , presstime = 0
    }
