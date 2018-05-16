module Tests exposing (suite)

import Dict
import HtmlParser exposing (Node(..))
import Testing.CustomTest exposing (Test, describe, test)
import Testing.Expect as Expect exposing (Expectation)


testParseAll : String -> List Node -> (() -> Expectation)
testParseAll s astList =
    \_ ->
        Expect.equal (Ok astList) (HtmlParser.run s)


testParse : String -> Node -> (() -> Expectation)
testParse s ast =
    testParseAll s [ ast ]


textNodeTests : Test
textNodeTests =
    describe "TextNode"
        [ test "basic" (testParse "1" (Text "1"))
        , test "basic" (testParse "a" (Text "a"))
        , test "basic" (testParse "1a" (Text "1a"))
        , test "basic" (testParse "^" (Text "^"))
        , test "decode1" (testParse "&" (Text "&"))
        , test "decode2" (testParse "&amp;" (Text "&"))
        , test "decode3" (testParse "&lt;" (Text "<"))
        , test "decode4" (testParse "&gt;" (Text ">"))
        , test "decode5" (testParse "&nbsp;" (Text " "))
        , test "decode6" (testParse "&apos;" (Text "'"))
        , test "decode7" (testParse "&#38;" (Text "&"))
        , test "decode8" (testParse "&#x26;" (Text "&"))
        , test "decode9" (testParse "&#x3E;" (Text ">"))
        , test "decodeA" (testParse "&#383;" (Text "ſ"))
        , test "decodeB" (testParse "&nbsp;" (Text " "))
        , test "decodeC" (testParse "&nbsp;&nbsp;" (Text "  "))
        , test "decodeD" (testParse "a&nbsp;b" (Text "a b"))
        , test "decodeE" (testParse "a&nbsp;&nbsp;b" (Text "a  b"))
        , test "decodeF" (testParse """<img alt="&lt;">""" (Element "img" [ ( "alt", "<" ) ] []))
        ]


nodeTests : Test
nodeTests =
    describe "Node"
        [ test "basic1" (testParse "<a></a>" (Element "a" [] []))
        , test "basic2" (testParse "<a></a >" (Element "a" [] []))
        , test "basic3" (testParse "<A></A >" (Element "a" [] []))
        , test "basic4" (testParseAll " <a></a> " [ Text " ", Element "a" [] [], Text " " ])
        , test "basic5" (testParseAll "a<a></a>b" [ Text "a", Element "a" [] [], Text "b" ])
        , test "basic6" (testParse "<A></A>" (Element "a" [] []))
        , test "basic7" (testParse "<a>a</a>" (Element "a" [] [ Text "a" ]))
        , test "basic8" (testParse "<a> a </a>" (Element "a" [] [ Text " a " ]))
        , test "basic10" (testParse "<br>" (Element "br" [] []))
        , test "basic11" (testParse "<a><a></a></a>" (Element "a" [] [ Element "a" [] [] ]))
        , test "basic12" (testParse "<a> <a> </a> </a>" (Element "a" [] [ Text " ", Element "a" [] [ Text " " ], Text " " ]))
        , test "basic13" (testParse "<a> <br> </a>" (Element "a" [] [ Text " ", Element "br" [] [], Text " " ]))
        , test "basic14" (testParse "<a><a></a><a></a></a>" (Element "a" [] [ Element "a" [] [], Element "a" [] [] ]))
        , test "basic15" (testParse "<a><a><a></a></a></a>" (Element "a" [] [ Element "a" [] [ Element "a" [] [] ] ]))
        , test "basic16" (testParse "<a><a></a><b></b></a>" (Element "a" [] [ Element "a" [] [], Element "b" [] [] ]))
        , test "basic17" (testParse "<h1></h1>" (Element "h1" [] []))
        , test "start-only-tag" (testParse "<br>" (Element "br" [] []))
        , test "start-only-tag" (testParse "<BR>" (Element "br" [] []))
        , test "start-only-tag" (testParse "<br >" (Element "br" [] []))
        , test "start-only-tag" (testParse "<BR >" (Element "br" [] []))
        , test "start-only-tag" (testParse "<a> <br> </a>" (Element "a" [] [ Text " ", Element "br" [] [], Text " " ]))
        , test "start-only-tag" (testParse "<a><br><br></a>" (Element "a" [] [ Element "br" [] [], Element "br" [] [] ]))
        , test "start-only-tag" (testParse "<a><br><img><hr><meta></a>" (Element "a" [] [ Element "br" [] [], Element "img" [] [], Element "hr" [] [], Element "meta" [] [] ]))
        , test "start-only-tag" (testParse "<a>foo<br>bar</a>" (Element "a" [] [ Text "foo", Element "br" [] [], Text "bar" ]))
        ]



-- see https://html.spec.whatwg.org/multipage/syntax.html#optional-tags


optionalEndTagTests : Test
optionalEndTagTests =
    describe "OptionalEndTag"
        [ test "ul" (testParse "<ul><li></li></ul>" (Element "ul" [] [ Element "li" [] [] ]))
        , test "ul" (testParse "<ul><li></ul>" (Element "ul" [] [ Element "li" [] [] ]))
        , test "ul" (testParse "<ul><li><li></ul>" (Element "ul" [] [ Element "li" [] [], Element "li" [] [] ]))
        , test "ul" (testParse "<ul><li></li><li></ul>" (Element "ul" [] [ Element "li" [] [], Element "li" [] [] ]))
        , test "ul" (testParse "<ul><li><li></li></ul>" (Element "ul" [] [ Element "li" [] [], Element "li" [] [] ]))
        , test "ul" (testParse "<ul><li><ul></ul></ul>" (Element "ul" [] [ Element "li" [] [ Element "ul" [] [] ] ]))
        , test "ul" (testParse "<ul> <li> <li> </ul>" (Element "ul" [] [ Text " ", Element "li" [] [ Text " " ], Element "li" [] [ Text " " ] ]))
        , test "ol" (testParse "<ol><li></ol>" (Element "ol" [] [ Element "li" [] [] ]))
        , test "tr" (testParse "<tr><td></tr>" (Element "tr" [] [ Element "td" [] [] ]))
        , test "tr" (testParse "<tr><td><td></tr>" (Element "tr" [] [ Element "td" [] [], Element "td" [] [] ]))
        , test "tr" (testParse "<tr><th></tr>" (Element "tr" [] [ Element "th" [] [] ]))
        , test "tr" (testParse "<tr><th><th></tr>" (Element "tr" [] [ Element "th" [] [], Element "th" [] [] ]))
        , test "tr" (testParse "<tr><th><td></tr>" (Element "tr" [] [ Element "th" [] [], Element "td" [] [] ]))
        , test "tr" (testParse "<tr><td><th></tr>" (Element "tr" [] [ Element "td" [] [], Element "th" [] [] ]))
        , test "tbody" (testParse "<tbody><tr><td></tbody>" (Element "tbody" [] [ Element "tr" [] [ Element "td" [] [] ] ]))
        , test "tbody" (testParse "<tbody><tr><th><td></tbody>" (Element "tbody" [] [ Element "tr" [] [ Element "th" [] [], Element "td" [] [] ] ]))
        , test "tbody" (testParse "<tbody><tr><td><tr><td></tbody>" (Element "tbody" [] [ Element "tr" [] [ Element "td" [] [] ], Element "tr" [] [ Element "td" [] [] ] ]))
        , test "tbody" (testParse "<tbody><tr><th><td><tr><th><td></tbody>" (Element "tbody" [] [ Element "tr" [] [ Element "th" [] [], Element "td" [] [] ], Element "tr" [] [ Element "th" [] [], Element "td" [] [] ] ]))
        , test "table" (testParse "<table><caption></table>" (Element "table" [] [ Element "caption" [] [] ]))
        , test "table" (testParse "<table><caption><col></table>" (Element "table" [] [ Element "caption" [] [], Element "col" [] [] ]))
        , test "table" (testParse "<table><caption><colgroup><col></table>" (Element "table" [] [ Element "caption" [] [], Element "colgroup" [] [ Element "col" [] [] ] ]))
        , test "table" (testParse "<table><colgroup><col></table>" (Element "table" [] [ Element "colgroup" [] [ Element "col" [] [] ] ]))
        , test "table" (testParse "<table><thead><tr><th><tbody></table>" (Element "table" [] [ Element "thead" [] [ Element "tr" [] [ Element "th" [] [] ] ], Element "tbody" [] [] ]))
        , test "html" (testParse "<html>a" (Element "html" [] [ Text "a" ]))
        , test "html" (testParse "<html>a<head>b<body>c" (Element "html" [] [ Text "a", Element "head" [] [ Text "b" ], Element "body" [] [ Text "c" ] ]))
        ]


scriptTests : Test
scriptTests =
    describe "Script"
        [ test "script" (testParse """<script></script>""" (Element "script" [] []))
        , test "script" (testParse """<SCRIPT></SCRIPT>""" (Element "script" [] []))
        , test "script" (testParse """<script src="script.js">foo</script>""" (Element "script" [ ( "src", "script.js" ) ] [ Text "foo" ]))
        , test "script" (testParse """<script>var a = 0 < 1; b = 1 > 0;</script>""" (Element "script" [] [ Text "var a = 0 < 1; b = 1 > 0;" ]))
        , test "script" (testParse """<script><!----></script>""" (Element "script" [] [ Comment "" ]))
        , test "script" (testParse """<script>a<!--</script><script>-->b</script>""" (Element "script" [] [ Text "a", Comment "</script><script>", Text "b" ]))
        , test "style" (testParse """<style>a<!--</style><style>-->b</style>""" (Element "style" [] [ Text "a", Comment "</style><style>", Text "b" ]))
        ]


commentTests : Test
commentTests =
    describe "Comment"
        [ test "basic" (testParse """<!---->""" (Comment ""))

        --, test "basic" (testParse """<!--foo\t\x0D
        -->""" (Comment "foo\t\x0D\n "))
        , test "basic" (testParse """<!--<div></div>-->""" (Comment "<div></div>"))
        , test "basic" (testParse """<div><!--</div>--></div>""" (Element "div" [] [ Comment "</div>" ]))
        , test "basic" (testParse """<!--<!---->""" (Comment "<!--"))
        ]


attributeTests : Test
attributeTests =
    describe "Attribute"
        [ test "basic" (testParse """<a href="example.com"></a>""" (Element "a" [ ( "href", "example.com" ) ] []))
        , test "basic" (testParse """<a href='example.com'></a>""" (Element "a" [ ( "href", "example.com" ) ] []))
        , test "basic" (testParse """<a href=example.com></a>""" (Element "a" [ ( "href", "example.com" ) ] []))
        , test "basic" (testParse """<a HREF=example.com></a>""" (Element "a" [ ( "href", "example.com" ) ] []))
        , test "basic" (testParse """<a href=bare></a>""" (Element "a" [ ( "href", "bare" ) ] []))
        , test "basic" (testParse """<a href="example.com?a=b&amp;c=d"></a>""" (Element "a" [ ( "href", "example.com?a=b&c=d" ) ] []))
        , test "basic" (testParse """<a href="example.com?a=b&c=d"></a>""" (Element "a" [ ( "href", "example.com?a=b&c=d" ) ] []))
        , test "basic" (testParse """<input max=100 min = 10.5>""" (Element "input" [ ( "max", "100" ), ( "min", "10.5" ) ] []))
        , test "basic" (testParse """<input disabled>""" (Element "input" [ ( "disabled", "" ) ] []))
        , test "basic" (testParse """<input DISABLED>""" (Element "input" [ ( "disabled", "" ) ] []))
        , test "basic" (testParse """<meta http-equiv=Content-Type>""" (Element "meta" [ ( "http-equiv", "Content-Type" ) ] []))
        , test "basic" (testParse """<input data-foo2="a">""" (Element "input" [ ( "data-foo2", "a" ) ] []))
        , test "basic" (testParse """<html xmlns:v="urn:schemas-microsoft-com:vml"></html>""" (Element "html" [ ( "xmlns:v", "urn:schemas-microsoft-com:vml" ) ] []))
        , test "basic" (testParse """<link rel=stylesheet
        href="">""" (Element "link" [ ( "rel", "stylesheet" ), ( "href", "" ) ] []))
        ]


testInvalid : String -> String -> (() -> Expectation)
testInvalid included s =
    \_ ->
        Expect.true "" <| String.contains included <| Debug.toString <| HtmlParser.run s


suite : Test
suite =
    describe "HtmlParser"
        [ textNodeTests
        , nodeTests
        , commentTests
        , attributeTests
        ]
