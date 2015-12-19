'use strict';
const SocketServer = require('./SocketServer');
const koa = require('koa');
const route = require('koa-route');

const app = koa();

app.use(route.get('/', function*() {
  this.body = 'homepage';
}));

const httpServer = require('http').createServer();
const socketServer = new SocketServer(httpServer);
socketServer.listen(3001);

