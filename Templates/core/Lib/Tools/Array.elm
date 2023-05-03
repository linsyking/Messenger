module Lib.Tools.Array exposing
    ( delSame
    , locate
    )

{-| This module has some handy tools related to array.

@docs delSame

@docs locate

-}

import Array exposing (Array)


{-| delSame
-}
delSame : List a -> List a -> List a
delSame ls xs =
    case ls of
        l :: lps ->
            case List.head (List.reverse xs) of
                Nothing ->
                    delSame lps [ l ]

                Just x ->
                    if l == x then
                        delSame lps xs

                    else
                        delSame lps (xs ++ [ l ])

        [] ->
            xs


{-| locate
-}
locate : (a -> Bool) -> Array a -> List Int
locate f xs =
    let
        b =
            List.range 0 (Array.length xs - 1)

        res =
            List.filter
                (\i ->
                    case Array.get i xs of
                        Just x ->
                            if f x then
                                True

                            else
                                False

                        Nothing ->
                            False
                )
                b
    in
    res
