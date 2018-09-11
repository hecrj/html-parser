module Html.Parser exposing (run, Node(..))

{-| Parse HTML 5 in Elm.
See <https://www.w3.org/TR/html5/syntax.html>

@docs run, Node

-}

import Dict exposing (Dict)
import Hex
import Parser exposing ((|.), (|=), Parser)


{-| Run the parser!
-}
run : String -> Result (List Parser.DeadEnd) (List Node)
run =
    Parser.run (oneOrMore "node" node)



-- Node


{-| An HTML node. It can either be:

  - Text
  - Element (with its **tag name**, **attributes** and **children**)
  - Comment

-}
type Node
    = Text String
    | Element String (List Attribute) (List Node)
    | Comment String


type alias Attribute =
    ( String, String )


node : Parser Node
node =
    Parser.oneOf
        [ text
        , comment
        , tag
        ]



-- Text


text : Parser Node
text =
    Parser.oneOf
        [ Parser.getChompedString (chompOneOrMore (\c -> c /= '<' && c /= '&'))
        , characterReference
        ]
        |> oneOrMore "text element"
        |> Parser.map (String.join "" >> Text)


characterReference : Parser String
characterReference =
    Parser.succeed identity
        |. Parser.chompIf ((==) '&')
        |= Parser.oneOf
            [ Parser.backtrackable namedCharacterReference
                |. chompSemicolon
            , Parser.backtrackable numericCharacterReference
                |. chompSemicolon
            , Parser.succeed "&"
            ]


namedCharacterReference : Parser String
namedCharacterReference =
    Parser.getChompedString (chompOneOrMore Char.isAlpha)
        |> Parser.map
            (\reference ->
                Dict.get reference namedCharacterReferences
                    |> Maybe.withDefault ("&" ++ reference ++ ";")
            )


numericCharacterReference : Parser String
numericCharacterReference =
    let
        codepoint =
            Parser.oneOf
                [ Parser.succeed identity
                    |. Parser.chompIf (\c -> c == 'x' || c == 'X')
                    |= hexadecimal
                , Parser.int
                ]
    in
    Parser.succeed identity
        |. Parser.chompIf ((==) '#')
        |= Parser.map (Char.fromCode >> String.fromChar) codepoint



-- Element


tag : Parser Node
tag =
    Parser.succeed Tuple.pair
        |. Parser.chompIf ((==) '<')
        |= tagName
        |. Parser.chompWhile isSpaceCharacter
        |= tagAttributes
        |. Parser.chompIf ((==) '>')
        |> Parser.andThen
            (\( name, attributes ) ->
                if isVoidElement name then
                    Parser.succeed (Element name attributes [])

                else
                    Parser.succeed (Element name attributes)
                        |= many (Parser.backtrackable node)
                        |. closingTag name
            )


tagName : Parser String
tagName =
    Parser.getChompedString (chompOneOrMore Char.isAlphaNum)
        |> Parser.map String.toLower


tagAttributes : Parser (List Attribute)
tagAttributes = many tagAttribute


tagAttribute : Parser Attribute
tagAttribute =
    Parser.succeed Tuple.pair
        |= tagAttributeName
        |. Parser.chompWhile isSpaceCharacter
        |= tagAttributeValue
        |. Parser.chompWhile isSpaceCharacter


tagAttributeName : Parser String
tagAttributeName =
    Parser.getChompedString (chompOneOrMore isTagAttributeCharacter)
        |> Parser.map String.toLower


tagAttributeValue : Parser String
tagAttributeValue =
    Parser.oneOf
        [ Parser.succeed identity
            |. Parser.chompIf ((==) '=')
            |. Parser.chompWhile isSpaceCharacter
            |= Parser.oneOf
                [ tagAttributeUnquotedValue
                , tagAttributeQuotedValue '"'
                , tagAttributeQuotedValue '\''
                ]
        , Parser.succeed ""
        ]


tagAttributeUnquotedValue : Parser String
tagAttributeUnquotedValue =
    let
        isUnquotedValueChar c =
            not (isSpaceCharacter c) && c /= '"' && c /= '\'' && c /= '=' && c /= '<' && c /= '>' && c /= '`' && c /= '&'
    in
    Parser.oneOf
        [ chompOneOrMore isUnquotedValueChar
            |> Parser.getChompedString
        , characterReference
        ]
        |> oneOrMore "attribute value"
        |> Parser.map (String.join "")


tagAttributeQuotedValue : Char -> Parser String
tagAttributeQuotedValue quote =
    let
        isQuotedValueChar c =
            c /= quote && c /= '&'
    in
    Parser.succeed identity
        |. Parser.chompIf ((==) quote)
        |= (Parser.oneOf
                [ Parser.getChompedString (chompOneOrMore isQuotedValueChar)
                , characterReference
                ]
                |> many
                |> Parser.map (String.join "")
           )
        |. Parser.chompIf ((==) quote)


closingTag : String -> Parser ()
closingTag name =
    let
        chompName =
            chompOneOrMore (\c -> not (isSpaceCharacter c) && c /= '>')
                |> Parser.getChompedString
                |> Parser.andThen
                    (\closingName ->
                        if String.toLower closingName == name then
                            Parser.succeed ()

                        else
                            Parser.problem ("closing tag does not match opening tag: " ++ name)
                    )
    in
    Parser.chompIf ((==) '<')
        |. Parser.chompIf ((==) '/')
        |. chompName
        |. Parser.chompWhile isSpaceCharacter
        |. Parser.chompIf ((==) '>')



-- Comment


comment : Parser Node
comment =
    Parser.succeed Comment
        |. Parser.token "<!"
        |. Parser.token "--"
        |= Parser.getChompedString (Parser.chompUntil "-->")
        |. Parser.token "-->"



-- Void elements


isVoidElement : String -> Bool
isVoidElement name =
    List.member name voidElements


voidElements : List String
voidElements =
    [ "area"
    , "base"
    , "br"
    , "col"
    , "embed"
    , "hr"
    , "img"
    , "input"
    , "link"
    , "meta"
    , "param"
    , "source"
    , "track"
    , "wbr"
    ]



-- Character validators


isTagAttributeCharacter : Char -> Bool
isTagAttributeCharacter c =
    not (isSpaceCharacter c) && c /= '"' && c /= '\'' && c /= '>' && c /= '/' && c /= '='


isSpaceCharacter : Char -> Bool
isSpaceCharacter c =
    c == ' ' || c == '\t' || c == '\n' || c == '\u{000D}' || c == '\u{000C}'



-- Chomp


chompSemicolon : Parser ()
chompSemicolon =
    Parser.chompIf ((==) ';')


chompOneOrMore : (Char -> Bool) -> Parser ()
chompOneOrMore fn =
    Parser.chompIf fn
        |. Parser.chompWhile fn



-- Types


hexadecimal : Parser Int
hexadecimal =
    chompOneOrMore Char.isHexDigit
        |> Parser.getChompedString
        |> Parser.andThen
            (\hex ->
                case Hex.fromString (String.toLower hex) of
                    Ok value ->
                        Parser.succeed value

                    Err error ->
                        Parser.problem error
            )



-- Loops


many : Parser a -> Parser (List a)
many parser_ =
    Parser.loop []
        (\list ->
            Parser.oneOf
                [ parser_ |> Parser.map (\new -> Parser.Loop (new :: list))
                , Parser.succeed (Parser.Done (List.reverse list))
                ]
        )


oneOrMore : String -> Parser a -> Parser (List a)
oneOrMore type_ parser_ =
    Parser.loop []
        (\list ->
            Parser.oneOf
                [ parser_ |> Parser.map (\new -> Parser.Loop (new :: list))
                , if List.isEmpty list then
                    Parser.problem ("expecting at least one " ++ type_)

                  else
                    Parser.succeed (Parser.Done (List.reverse list))
                ]
        )



-- Addendum


namedCharacterReferences : Dict String String
namedCharacterReferences =
    -- TODO: Complete this
    [ ( "amp", "&" )
    , ( "lt", "<" )
    , ( "gt", ">" )
    , ( "nbsp", " " )
    , ( "apos", "'" )
    ]
        |> Dict.fromList
