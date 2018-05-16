module Testing.CustomTest exposing (Test, describe, test, toHtml)

import Html exposing (Html)
import Html.Attributes as Attributes
import Testing.Expect as Expect exposing (Expectation)


type Test
    = Test String (() -> Expectation)
    | Suite String (List Test)


test : String -> (() -> Expectation) -> Test
test =
    Test


describe : String -> List Test -> Test
describe =
    Suite


toHtml : Test -> Html msg
toHtml test_ =
    case test_ of
        Test name runner ->
            case Expect.result (runner ()) of
                Ok () ->
                    Html.li []
                        [ Html.text (name ++ " ... ")
                        , Html.span [ Attributes.style "color" "green" ] [ Html.text "OK" ]
                        ]

                Err error ->
                    Html.li []
                        [ Html.p []
                            [ Html.text (name ++ " ... ")
                            , Html.span [ Attributes.style "color" "red" ] [ Html.text "FAILED" ]
                            ]
                        , Html.text error
                        ]

        Suite name tests ->
            Html.div []
                [ Html.span [ Attributes.style "font-weight" "bold" ] [ Html.text name ]
                , Html.ol [ Attributes.style "margin-left" "2em" ]
                    (List.map toHtml tests)
                ]
