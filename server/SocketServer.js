'use strict';

const makeSocket = require('socket.io');
const CBuffer = require('CBuffer');
const faker = require('faker');

const generateId = (function() {
  let prevId = 0;
  return function _generateId() {
    return ++prevId;
  };
})();

function generateMessage(uname, text) {
  const message = {
    id: generateId(),
    when: new Date().toISOString(),
    text: text || faker.lorem.sentence(),
    uname: uname || faker.internet.userName()
  };

  return message;
}

function SocketServer(httpServer) {
  this.socket = makeSocket(httpServer);
  this.httpServer = httpServer;

  // STATE
  this.clients = new Set();
  this.messages = new CBuffer(250);
  
  // SETUP TOY STATE
  this.messages.push(generateMessage());
  this.messages.push(generateMessage());
  this.messages.push(generateMessage());

  // ATTACH SOCKET LISTENERS
  this.socket.on('connect', this.onConnect.bind(this));
}

function emit1(socket) { 
  console.log('emiting 1');
  socket.emit('arity1', 'foo'); 
};
function emit2(socket) {
  console.log('emiting 2');
  socket.emit('arity2', 'apples', 'oranges'); 
};
function emit3(socket) {
  console.log('emiting 3');
  socket.emit('arity3', 'x', 'y', 'z'); 
};

SocketServer.prototype.onConnect = function(clientSocket) {
  const self = this;
  console.log('a client connected');

  clientSocket.on('arity1', function(v1) {
    console.log('received arity1, v1=%j', v1);
  });
  clientSocket.on('arity1_with_callback', function(shouldSucceed, cb) {
    console.log('received arity1_with_callback, shouldSucceed=%j', shouldSucceed);
    if (shouldSucceed)
      cb();
    else
      cb('TOO_WEAK');
  });
  clientSocket.on('arity2', function(v1, v2) {
    console.log('received arity2, v1=%j, v2=%j', v1, v2);
  });
  clientSocket.on('arity2_with_callback', function(shouldSucceed, v2, cb) {
    console.log('received arity2_with_callback, shouldSucceed=%j, v2=%j', shouldSucceed, v2);
    if (shouldSucceed)
      cb();
    else
      cb('TOO_TALL');
  });
  clientSocket.on('arity3', function(v1, v2, v3) {
    console.log('received arity3, v1=%j, v2=%j, v3=%j', v1, v2, v3);
  });
  clientSocket.on('arity3_with_callback', function(shouldSucceed, v2, v3, cb) {
    console.log('received arity3_with_callback, shouldSucceed=%j, v2=%j, v3=%j', shouldSucceed, v2, v3);
    if (shouldSucceed)
      cb();
    else
      cb('TOO_IMPOSSIBLE');
  });

  //clientSocket.emit('arity1', 'data1');
  emit1(clientSocket);
  emit2(clientSocket);
  emit3(clientSocket);
};

SocketServer.prototype.listen = function(port) {
  this.httpServer.listen(port, function() {
    console.log('listening on port', port);
  });
};

module.exports = SocketServer;
