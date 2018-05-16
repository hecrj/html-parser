# html-parser

Parse HTML 5 in Elm 0.19!

I wanted to play with `elm-lang/parser` a bit, so I decided to go ahead
and try to parse HTML 5, as I need this in order to port some Elm apps.

This is very WIP, and it probably has _many_ issues still. I have only
been able to pass the sane tests in the [`jinjor/elm-html-parser`] package
for Elm 0.18. Feel free to fork, contribute, add new tests and/or open issues!

## Testing in Elm 0.19

I am currently using some quickly hand-made `Testing` modules that mock
a small subset of the `elm-test` API for Elm 0.18 and render the test results
in HTML using `elm-lang/browser`.

You can use `elm reactor` to open the `RunTests.elm` file. The test suite
is located in the `Tests` module.
