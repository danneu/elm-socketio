
# elm-socketio

(Experimental, unreleased, messy, work-in-progress)

A Socket.io client wrapper for Elm.

This library is drop-in replacement for [mgold/elm-socketio][mgold]
with an expanded scope aimed at supporting the Socket.io
features necessary for communicating with Socket.io servers
that you do *not* control.

## This vs. [mgold/elm-socketio][mgold]

@mgold clarified to me that [mgold/elm-socketio][mgold] was intended
to be used with Socket.io servers that *you* control, so things like higher arity
support were out of his library's scope.

[mgold/elm-socketio][mgold] only supports emitting/receiving
single arity payloads:

``` javascript
// Client

socket.on('event', payload1 => ...)
socket.emit('event', payload1)
```

However, this was insufficient for me because I needed to talk to Socket.io
servers that emit/receive higher arity payloads:

``` javascript
// Client

socket.emit('event', payload1, payload2)
socket.emit('event', payload1, payload2, payload3)
socket.on('event', (payload1, payload2) => ...)
socket.on('event', (payload1, payload2, payload3) => ...)
```

Further, I also needed to talk to Socket.io servers that use Socket.io's
callback reply system:

``` javascript
// Client

socket.emit('new_message', text, function(err) {
  if (err) {
    // `err` is 'USER_IS_MUTED' | 'USER_IS_FLOODING' | 'INTERNAL_ERROR'
    return;
  }
  // Else, the server accepted the message
});

// Server

socket.on('new_message', function(text, cb) {
  if (isMuted(user)) {
    return cb('USER_IS_MUTED');
  } else if (isFlooding(user)) {
    return cb('USER_IS_FLOODING');
  }

  db.insertMessage(user, text, function(err) {
    if (err) {
      return cb('INTERNAL_ERROR');
    }

    // Successfully saved message, so reply to client without an error
    cb();
  });
});
```

And I also needed to use this callback reply system with payloads
of higher arity:

``` javascript
socket.emit('new_message', payload1, payload2, cb);
socket.emit('new_message', payload1, payload2, payload3, cb);
```

[mgold]: https://github.com/mgold/elm-socketio
