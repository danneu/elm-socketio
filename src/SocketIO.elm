
module SocketIO where

import Native.SocketIO

import Time
import Task
import Native.SocketIO
import Json.Encode as JE

type Socket = Socket

-- CONNECTING

type alias Options =
  { multiplex : Bool
  , reconnection : Bool
  , reconnectionDelay : Time.Time
  , reconnectionDelayMax : Time.Time
  , timeout : Time.Time
  }

defaultOptions : Options
defaultOptions =
  { multiplex = False
  , reconnection = True
  , reconnectionDelay = 1000
  , reconnectionDelayMax = 5000
  , timeout = 20000
  }

io : String -> Options -> Task.Task x Socket
io = Native.SocketIO.io

-- EMITTING

emit : String -> JE.Value -> Socket -> Task.Task x ()
emit = Native.SocketIO.emit

emit2 : String -> JE.Value -> JE.Value -> Socket -> Task.Task x ()
emit2 = Native.SocketIO.emit2

emit3 : String -> JE.Value -> JE.Value -> JE.Value -> Socket -> Task.Task x ()
emit3 = Native.SocketIO.emit3

emitWithCallback : String -> JE.Value -> (Result err ok -> Result err' ok') -> Socket -> Task.Task x b
emitWithCallback =
  Native.SocketIO.emitWithCallback

emit2WithCallback : String -> JE.Value -> JE.Value -> (Result err ok -> Result err' ok') -> Socket -> Task.Task x b
emit2WithCallback =
  Native.SocketIO.emit2WithCallback

emit3WithCallback : String -> JE.Value -> JE.Value -> JE.Value -> (Result err ok -> Result err' ok') -> Socket -> Task.Task x b
emit3WithCallback =
  Native.SocketIO.emit3WithCallback

-- LISTENING

on : String -> Signal.Address String -> Socket -> Task.Task x ()
on = Native.SocketIO.on

on2 : String -> Signal.Address (String, String) -> Socket -> Task.Task x ()
on2 = Native.SocketIO.on2

on3 : String -> Signal.Address (String, String, String) -> Socket -> Task.Task x ()
on3 = Native.SocketIO.on3

-- STATUS

connected : Signal.Address Bool -> Socket -> Task.Task x ()
connected = Native.SocketIO.connected
