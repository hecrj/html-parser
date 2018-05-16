module Testing.Expect exposing (Expectation, equal, result, true)


type Expectation
    = Expectation (Result String ())


equal : a -> a -> Expectation
equal a b =
    if a == b then
        Expectation (Ok ())

    else
        Expectation (Err (Debug.toString b ++ "\n\nshould equal\n\n" ++ Debug.toString a))


true : String -> Bool -> Expectation
true _ a =
    if a then
        Expectation (Ok ())

    else
        Expectation (Err (Debug.toString a ++ "\n\nshould be true"))


result : Expectation -> Result String ()
result (Expectation result_) =
    result_
