module Lib.LocalStorage.LocalStorage exposing
    ( decodeLSInfo
    , encodeLSInfo
    )

{-| This is the doc for this module

Store some gamedata.

@docs decodeLSInfo

@docs encodeLSInfo

@docs isFirstPlay

-}

import Base exposing (LSInfo)
import Json.Decode as Decode exposing (at, decodeString)
import Json.Encode as Encode


{-| decodeLSInfo

Decode the string to LSInfo.

When the game starts, it will run this function to load the data from localstorage.

-}
decodeLSInfo : String -> LSInfo
decodeLSInfo info =
    let
        oldvol =
            Result.withDefault 0.5 (decodeString (at [ "volume" ] Decode.float) info)
    in
    LSInfo oldvol


{-| encodeLSInfo

Encode the LSInfo to string.

When needed, it will run this function to save the data to localstorage.

-}
encodeLSInfo : LSInfo -> String
encodeLSInfo info =
    Encode.encode 0
        (Encode.object
            [ ( "volume", Encode.float info.volume )
            ]
        )
