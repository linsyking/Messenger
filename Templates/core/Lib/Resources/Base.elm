module Lib.Resources.Base exposing
    ( getResourcePath
    , getTexture
    , saveSprite
    , igetSprite
    , allTexture
    )

{-|


# Resource

There are many assets (images) in our game, so it's important to manage them.

In elm-canvas, we have to preload all the images before the game starts.

The game will only start when all resources are loaded.

After the resources are loaded, we can get those data from globaldata.sprites.

@docs getResourcePath

@docs getTexture

@docs saveSprite

@docs igetSprite

@docs allTexture

-}

import Base exposing (Msg(..))
import Canvas.Texture as Texture exposing (Texture)
import Dict exposing (Dict)


{-| getResourcePath
-}
getResourcePath : String -> String
getResourcePath x =
    "assets/" ++ x


{-| getTexture
-}
getTexture : List (Texture.Source Msg)
getTexture =
    List.map (\( x, y ) -> Texture.loadFromImageUrl y (TextureLoaded x)) allTexture


{-| saveSprite
-}
saveSprite : Dict String Texture -> String -> Texture -> Dict String Texture
saveSprite dst name text =
    Dict.insert name text dst


{-| igetSprite
-}
igetSprite : String -> Dict String Texture -> Maybe Texture
igetSprite name dst =
    Dict.get name dst


{-| allTexture

Add your textures here.

-}
allTexture : List ( String, String )
allTexture =
    [ ( "ball", getResourcePath "img/ball.png" )
    ]
