module Model exposing (Model)

-- This is the model in common among all of our apps


type alias Model =
    { result: Float, selectedContent: Int, exrateTWD: Float, exrateJPY: Float }
