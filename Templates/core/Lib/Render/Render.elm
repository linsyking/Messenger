module Lib.Render.Render exposing
    ( transPoint
    , renderSprite
    , renderSpriteWithRev
    , renderText
    , renderTextWithColor
    , renderSpriteRawPos
    )

{-| This is the doc for this module

@docs transPoint

@docs renderSprite

@docs renderSpriteWithRev

@docs renderText

@docs renderTextWithColor

@docs renderSpriteRawPos

-}

import Base exposing (GlobalData)
import Canvas exposing (Point, Renderable, text, texture)
import Canvas.Settings exposing (Setting, fill)
import Canvas.Settings.Advanced exposing (scale, transform, translate)
import Canvas.Settings.Text exposing (TextAlign(..), align, font)
import Canvas.Texture exposing (dimensions)
import Color exposing (Color)
import Lib.Coordinate.Coordinates exposing (heightToReal, posToReal, widthToReal)
import Lib.Resources.Base exposing (igetSprite)


{-| transPoint
-}
transPoint : GlobalData -> ( Int, Int ) -> Point
transPoint gd p =
    posToReal gd p


{-| renderSprite
-}
renderSprite : GlobalData -> List Setting -> ( Int, Int ) -> ( Int, Int ) -> String -> Renderable
renderSprite gd ls p ( w, h ) name =
    let
        dst =
            gd.sprites
    in
    case igetSprite name dst of
        Just t ->
            let
                text_dim =
                    dimensions t

                rw =
                    widthToReal gd w

                rh =
                    heightToReal gd h

                text_width =
                    text_dim.width

                text_height =
                    text_dim.height

                width_s =
                    rw / text_width

                height_s =
                    rh / text_height

                ( newx, newy ) =
                    transPoint gd p
            in
            if w > 0 && h > 0 then
                texture
                    (transform
                        [ translate newx newy
                        , scale width_s height_s
                        ]
                        :: ls
                    )
                    ( 0, 0 )
                    t

            else if w > 0 && h <= 0 then
                texture
                    (transform
                        [ translate newx newy
                        , scale width_s width_s
                        ]
                        :: ls
                    )
                    ( 0, 0 )
                    t

            else if w <= 0 && h > 0 then
                texture
                    (transform
                        [ translate newx newy
                        , scale height_s height_s
                        ]
                        :: ls
                    )
                    ( 0, 0 )
                    t

            else
                -- All <= 0
                texture
                    ls
                    ( newx, newy )
                    t

        Nothing ->
            text [] (transPoint gd p) ""


{-| renderSpriteRawPos
-}
renderSpriteRawPos : GlobalData -> List Setting -> ( Float, Float ) -> ( Int, Int ) -> String -> Renderable
renderSpriteRawPos gd ls p ( w, h ) name =
    let
        dst =
            gd.sprites
    in
    case igetSprite name dst of
        Just t ->
            let
                text_dim =
                    dimensions t

                rw =
                    widthToReal gd w

                rh =
                    heightToReal gd h

                text_width =
                    text_dim.width

                text_height =
                    text_dim.height

                width_s =
                    rw / text_width

                height_s =
                    rh / text_height

                ( newx, newy ) =
                    p
            in
            if w > 0 && h > 0 then
                texture
                    (transform
                        [ translate newx newy
                        , scale width_s height_s
                        ]
                        :: ls
                    )
                    ( 0, 0 )
                    t

            else if w > 0 && h <= 0 then
                texture
                    (transform
                        [ translate newx newy
                        , scale width_s width_s
                        ]
                        :: ls
                    )
                    ( 0, 0 )
                    t

            else if w <= 0 && h > 0 then
                texture
                    (transform
                        [ translate newx newy
                        , scale height_s height_s
                        ]
                        :: ls
                    )
                    ( 0, 0 )
                    t

            else
                -- All <= 0
                texture
                    ls
                    ( newx, newy )
                    t

        Nothing ->
            text [] p ""


{-| renderSpriteWithRev
-}
renderSpriteWithRev : Bool -> GlobalData -> List Setting -> ( Int, Int ) -> ( Int, Int ) -> String -> Renderable
renderSpriteWithRev rev gd ls p ( w, h ) name =
    if not rev then
        renderSprite gd ls p ( w, h ) name

    else
        let
            dst =
                gd.sprites
        in
        case igetSprite name dst of
            Just t ->
                let
                    text_dim =
                        dimensions t

                    rw =
                        widthToReal gd w

                    rh =
                        heightToReal gd h

                    text_width =
                        text_dim.width

                    text_height =
                        text_dim.height

                    width_s =
                        rw / text_width

                    height_s =
                        rh / text_height

                    ( newx, newy ) =
                        transPoint gd p
                in
                if w > 0 && h > 0 then
                    texture
                        (transform
                            [ translate newx newy
                            , scale -width_s width_s
                            , translate -text_width 0
                            ]
                            :: ls
                        )
                        ( 0, 0 )
                        t

                else if w > 0 && h <= 0 then
                    texture
                        (transform
                            [ translate newx newy
                            , scale -width_s width_s
                            , translate -text_width 0
                            ]
                            :: ls
                        )
                        ( 0, 0 )
                        t

                else if w <= 0 && h > 0 then
                    texture
                        (transform
                            [ translate newx newy
                            , scale -height_s height_s
                            , translate -text_width 0
                            ]
                            :: ls
                        )
                        ( 0, 0 )
                        t

                else
                    -- All <= 0
                    texture
                        ls
                        ( newx, newy )
                        t

            Nothing ->
                text [] (transPoint gd p) "Wrong Sprite"


{-| renderText
-}
renderText : GlobalData -> Int -> String -> String -> ( Int, Int ) -> Renderable
renderText gd size s ft ( x, y ) =
    let
        rx =
            heightToReal gd size

        ( dsx, dsy ) =
            posToReal gd ( x, y )
    in
    text
        [ font { size = floor rx, family = ft }
        , align Start
        ]
        ( dsx, dsy + rx - 1 )
        s


{-| renderTextWithColor
-}
renderTextWithColor : GlobalData -> Int -> String -> String -> Color -> ( Int, Int ) -> Renderable
renderTextWithColor gd size s ft col ( x, y ) =
    let
        rx =
            heightToReal gd size

        ( dsx, dsy ) =
            posToReal gd ( x, y )
    in
    text
        [ font { size = floor rx, family = ft }
        , align Start
        , fill col
        ]
        ( dsx, dsy + rx - 1 )
        s
