# SocketBox

WebSocket Listener library to be used with CommandBox Websocket and BoxLang WebSocket server.

## About
The WebSocket server in CommandBox and BoxLang MiniServer is not really a separate "server" per se, since it’s on the same port.  It’s just an upgrade listener which will upgrade any WS requests.  

This websocket integration will work for Lucee, Adobe, and BoxLang alike as it passes incoming messages to the app via an "internal" HTTP request to  `/WebSocket.cfc?method=onProcess` where the CF/BL code can handle it.  The incoming request will have all cookies, headers, hostname, etc that the original websocket connection was started with, so normal CGI variables and session scopes should work fine.  

You need to create a custom `/WebSocket.cfc` class should extend the `modules.socketbox.models.WebSocketCore` class in this library which provides the base functionality.

## Configure

The BoxLang Miniserver doesn't have any configuration ATM.  It uses the defaults.

CommandBox allows for the following config:

* Whether or not the websocket handler is active.  Toggle for all sites under `web.websocket.enable` and for an individual site under `sites.mySite.websocket.enable`.  `true`/`false`
* The URI the websockets listener will listen on.  Default is `/ws` so if your site is `foobar.com` then your JS code in the browser will connect to `foobar.com/ws`.  Configure under `web.websocket.uri` for all sites and for an individual site under `sites.mySite.websocket.uri`.  You can use the root URI of `/` but you may have issues setting up websocket proxying if you have a web server in front.
* The publicly accessible remote class (cfc or bx) to respond to incoming websocket messages.  Default is `/WebSocket.cfc` in the web root,  Configure for all sites with `web.websocket.listener` and for an individual site under `sites.mySite.websocket.listener`.

#Usage 

Methods you can override in your custom `/WebSocket.cfc` are:

* `onConnect( required channel )` - called for every new remote connection
* `onClose( required channel )` - called every time a connection is closed
* `onMessage( required message, required channel )` - called every time an incoming message is received.  The message will be a string.

Other methods inherited from the the `WebSocketCore.cfc` you can use.

* `sendMessage( required message, required channel )` - Send a string message to a specific channel
* `broadcastMessage( required message )` - Send a string message to every connected channel
* `getAllConnections()` - Returns an array of all channels representing every remote connection to the server.

None of these methods return any values.  If you, for instance, want to reply back to a websocket message with another message, you can re-use the channel like so:

```js
function onMessage( required message, required channel ) {
    if( message EQ "Ping" ) {
        sendMessage( "Pong", arguments.channel );
    }
}
```

There are no topic or subscription semantics right now.  The base library just provides the bare minimum to send and receive messages.  You can build whatever you want on top of this.  We’ll probably add something like STOMP on top of this in the future. 
