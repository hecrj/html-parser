module RunTests exposing (main)

import Browser
import Html exposing (Html)
import Testing.CustomTest as CustomTest
import Tests


main : Program () () msg
main =
    Browser.sandbox
        { init = ()
        , update = \_ _ -> ()
        , view = always (CustomTest.toHtml Tests.suite)
        }
