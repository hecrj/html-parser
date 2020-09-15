module Html.Parser.Util exposing (toVirtualDom)

{-| Utility functions that may help you digging into the contents.


# Virtual DOM

@docs toVirtualDom

-}

import Html exposing (Attribute, Html, text)
import Html.Attributes exposing (attribute, property)
import Html.Parser exposing (Node(..))
import Json.Encode as Encode


{-| Converts nodes to virtual dom nodes.
-}
toVirtualDom : List Node -> List (Html msg)
toVirtualDom nodes =
    List.map toVirtualDomEach nodes


toVirtualDomEach : Node -> Html msg
toVirtualDomEach node =
    case node of
        Element name attrs children ->
            Html.node name
                (List.map
                    (case name of
                        "video" ->
                            toVideoAttribute

                        _ ->
                            toAttribute
                    )
                    attrs
                )
                (toVirtualDom children)

        Text s ->
            text s

        Comment _ ->
            text ""


toAttribute : ( String, String ) -> Attribute msg
toAttribute ( name, value ) =
    attribute name value


toVideoAttribute : ( String, String ) -> Attribute msg
toVideoAttribute ( name, value ) =
    case name of
        "muted" ->
            stringToBool value
                |> Encode.bool
                |> property name

        _ ->
            attribute name value


stringToBool : String -> Bool
stringToBool str =
    case (String.trim >> String.toLower) str of
        "false" ->
            False

        "no" ->
            False

        _ ->
            True
