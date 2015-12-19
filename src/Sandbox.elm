
module Sandbox where

import SocketIO

import Effects exposing (Effects)
import Html exposing (..)
import Task exposing (andThen)
import Json.Encode as JE

-- MODEL

type alias Model =
  {
  }

init : (Model, Effects Action)
init =
  ({}, connect)

-- UPDATE

type ValidationError
  = TooCool
  | TooTall
  | TooWeak
  -- When server sends us error we don't handle.
  -- For example, if the server's api docs are outdated and it sends
  -- you an error code that you don't know about.
  | Unknown

type Action
  = NoOp
  | Connected
  | Recv1 String
  | Recv2 (String, String)
  | Recv3 (String, String, String)
  -- With callback
  | HandleEmit1WithCallbackResponse (Result ValidationError ())
  | HandleEmit2WithCallbackResponse (Result ValidationError ())
  | HandleEmit3WithCallbackResponse (Result ValidationError ())
  -- Status change
  | StatusChange Bool

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    NoOp ->
      (model, Effects.none)
    Connected ->
      let
        _ = Debug.log "[Connected]" ()
      in
        ( model
        , Effects.batch
            [ emit1Test 42
            , emit2Test "alpha" "omega"
            , emit3Test "x" "y" "z"
            , emit1WithCallbackTest True
            , emit1WithCallbackTest False
            , emit2WithCallbackTest True "whatever"
            , emit2WithCallbackTest False "whatever"
            , emit3WithCallbackTest True "apples" 42
            , emit3WithCallbackTest False "apples" 42
            ]
        )
    Recv1 v1 ->
      let
        _ = Debug.log "[Recv1]" v1
      in
        (model, Effects.none)
    Recv2 (v1, v2) ->
      let
        _ = Debug.log "[Recv2]" (v1, v2)
      in
        (model, Effects.none)
    Recv3 (v1, v2, v3) ->
      let
        _ = Debug.log "[Recv3]" (v1, v2, v3)
      in
        (model, Effects.none)
    -- With callback
    HandleEmit1WithCallbackResponse result ->
      let
        _ = Debug.log "[HandleEmit1WithCallbackResponse]" result
      in
        (model, Effects.none)
    HandleEmit2WithCallbackResponse result ->
      let
        _ = Debug.log "[HandleEmit2WithCallbackResponse]" result
      in
        (model, Effects.none)
    HandleEmit3WithCallbackResponse result ->
      let
        _ = Debug.log "[HandleEmit3WithCallbackResponse]" result
      in
        (model, Effects.none)
    StatusChange isConnected ->
      let
        _ = Debug.log "[StatusChange] isConnected: " isConnected
      in
        (model, Effects.none)


-- VIEW

view : Signal.Address Action -> Model -> Html
view address model =
  div
  []
  [ text "Hello, world!"
  ]

(=>) : a -> b -> (a, b)
(=>) = (,)

-- MAILBOXES

box1 : Signal.Mailbox String
box1 =
  Signal.mailbox "null"

box2 : Signal.Mailbox (String, String)
box2 =
  Signal.mailbox ("null", "null")

box3 : Signal.Mailbox (String, String, String)
box3 =
  Signal.mailbox ("null", "null", "null")

statusBox : Signal.Mailbox Bool
statusBox =
  Signal.mailbox False

inputs : Signal Action
inputs =
  Signal.mergeMany
    [ Signal.map Recv1 box1.signal
    , Signal.map Recv2 box2.signal
    , Signal.map Recv3 box3.signal
    , Signal.map StatusChange statusBox.signal
    ]

-- EFFECTS

getSocket : Task.Task x SocketIO.Socket
getSocket =
  SocketIO.io "http://localhost:3001" SocketIO.defaultOptions

connect : Effects Action
connect =
  getSocket
  `andThen` (\socket ->
    Task.succeed ()
    `andThen` always (SocketIO.on "arity1" box1.address socket)
    `andThen` always (SocketIO.on2 "arity2" box2.address socket)
    `andThen` always (SocketIO.on3 "arity3" box3.address socket)
    `andThen` always (SocketIO.connected statusBox.address socket)
  )
  |> Effects.task
  |> Effects.map (always Connected)


emit1Test : Int -> Effects Action
emit1Test v1 =
  getSocket
  `andThen` (\socket ->
    SocketIO.emit "arity1" (JE.int v1) socket
  )
  |> Effects.task
  |> Effects.map (always NoOp)

emit2Test : String -> String -> Effects Action
emit2Test v1 v2 =
  getSocket
  `andThen` (\socket ->
    SocketIO.emit2 "arity2" (JE.string v1) (JE.string v2) socket
  )
  |> Effects.task
  |> Effects.map (always NoOp)


emit3Test : String -> String -> String -> Effects Action
emit3Test v1 v2 v3 =
  getSocket
  `andThen` (\socket ->
    let
      data1 = JE.string v1
      data2 = JE.string v2
      data3 = JE.string v3
    in
      SocketIO.emit3 "arity3" data1 data2 data3 socket
  )
  |> Effects.task
  |> Effects.map (always NoOp)

-- With callback

cb : Result String a -> Result ValidationError ()
cb result =
  case result of
    Err err ->
      case err of
        "TOO_COOL" -> Err TooCool
        "TOO_TALL" -> Err TooTall
        "TOO_WEAK" -> Err TooWeak
        _          -> Err Unknown
    Ok _ ->
      Ok ()

emit1WithCallbackTest : Bool -> Effects Action
emit1WithCallbackTest shouldSucceed =
  getSocket
  `andThen` (\socket ->
    let
      data1 = JE.bool shouldSucceed
    in
      SocketIO.emitWithCallback "arity1_with_callback" data1 cb socket
  )
  |> Effects.task
  |> Effects.map HandleEmit1WithCallbackResponse

emit2WithCallbackTest : Bool -> String -> Effects Action
emit2WithCallbackTest shouldSucceed v2 =
  getSocket
  `andThen` (\socket ->
    let
      data1 = JE.bool shouldSucceed
      data2 = JE.string v2
    in
      SocketIO.emit2WithCallback "arity2_with_callback" data1 data2 cb socket
  )
  |> Effects.task
  |> Effects.map HandleEmit2WithCallbackResponse

emit3WithCallbackTest : Bool -> String -> Int -> Effects Action
emit3WithCallbackTest shouldSucceed v2 v3 =
  getSocket
  `andThen` (\socket ->
    let
      data1 = JE.bool shouldSucceed
      data2 = JE.string v2
      data3 = JE.int v3
    in
      SocketIO.emit3WithCallback "arity3_with_callback" data1 data2 data3 cb socket
  )
  |> Effects.task
  |> Effects.map HandleEmit3WithCallbackResponse
