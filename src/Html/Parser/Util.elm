module Html.Parser.Util exposing
    ( toVirtualDom
    , toAttribute, toVirtualDomEach
    )

{-| Utility functions that may help you digging into the contents.


# Virtual DOM

@docs toVirtualDom, toVirtualDomSvg

-}

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Parser exposing (Node(..))
import Svg exposing (Svg)
import Svg.Attributes
import VirtualDom


{-| Converts nodes to virtual dom nodes.
-}
toVirtualDom : List Node -> List (Html msg)
toVirtualDom nodes =
    List.map toVirtualDomEach nodes


toVirtualDomEach : Node -> Html msg
toVirtualDomEach node =
    case node of
        Element name attrs children ->
            if name == "svg" then
                toVirtualDomSvgEach node

            else
                Html.node name (List.map toAttribute attrs) (toVirtualDom children)

        Text s ->
            text s

        Comment _ ->
            text ""


toAttribute : ( String, String ) -> Attribute msg
toAttribute ( name, value ) =
    attribute name value


{-| Converts nodes to virtual dom SVG nodes.

Note: If node list contains `<svg>` tag, you can use `toVirtualDom` instead.
Otherwise, use this function.

    svg : Svg msg
    svg =
        parse """<circle cx="40" cy="40" r="24" style="stroke:#006600; fill:#00cc00"/>"""
            |> toVirtualDomSvg
            |> Svg.svg []

-}
toVirtualDomSvg : List Node -> List (Svg msg)
toVirtualDomSvg nodes =
    List.map toVirtualDomSvgEach nodes


toVirtualDomSvgEach : Node -> Svg msg
toVirtualDomSvgEach node =
    case node of
        Element name attrs children ->
            Svg.node name (List.map toSvgAttribute attrs) (toVirtualDomSvg children)

        Text s ->
            text s

        Comment _ ->
            text ""


toSvgAttribute : ( String, String ) -> Attribute msg
toSvgAttribute ( name, value ) =
    if String.startsWith "xlink:" name then
        VirtualDom.attributeNS "http://www.w3.org/1999/xlink" name value

    else if String.startsWith "xml:" name then
        VirtualDom.attributeNS "http://www.w3.org/XML/1998/namespace" name value

    else
        VirtualDom.attribute name value
