
import Sandbox

import StartApp
import Task
import Effects
import Html

app : StartApp.App Sandbox.Model
app =
  StartApp.start
    { view = Sandbox.view
    , update = Sandbox.update
    , init = Sandbox.init
    , inputs = [Sandbox.inputs]
    }

main : Signal Html.Html
main =
  app.html

port tasks : Signal (Task.Task Effects.Never ())
port tasks =
  app.tasks
