/**
 * This is the base WebSocket core component that is used to handle WebSocket connections.
 * Use this in conjunction with CommandBox or the BoxLang Miniserver's websocket server.
 * Extend this CFC with a /WebSocket.cfc in your web root.
 */
component {
	variables.serverClass = "";
	variables.SITE_DEPLOYMENT_KEY = "";
	variables.WEBSOCKET_REQUEST_DETAILS = "";
	variables.serverType = detectServerType();
	
	/**
	 * Front controller for all WebSocket incoming messages
	 */
	remote function onProcess() {
		try {
			var WSMethod = arguments.WSMethod ?: "";
			var methodArgs = serverClass.getCurrentExchange().getAttachment( WEBSOCKET_REQUEST_DETAILS ) ?: [];
			var realArgs = [];
			// Adobe's argumentCollection doesn't work with a java.util.List :/
			for( var arg in methodArgs ) {
				realArgs.append( arg );
			}
			switch( WSMethod ) {
				case "onConnect":
					onConnect( argumentCollection=realArgs );
					break;
				case "onFullTextMessage":
					_onMessage( argumentCollection=realArgs );
					break;
				case "onClose":
					onClose( argumentCollection=realArgs );
					break;
				default:
					println("Unknown method: #WSMethod#");
			}
		} catch (any e) {
			e.printStackTrace();
			rethrow;
		}
	}

	/**********************************
	 * CONNECTION LIFECYCLE METHODS
	 **********************************/


	/**
	 * A new incoming connectino has been established
	 */
	function onConnect( required channel ) {
		//println("new connection on channel #channel.toString()#");
	}

	/**
	 * A connection has been closed
	 */
	function onClose( required channel ) {
		//println("connection closed on channel #channel.getPeerAddress().toString()#");
	}

	/**
	 * Get all connections
	 */
	function getAllConnections() {
		return getWSHandler().getConnections().toArray();
	}


	/**********************************
	 * INCOMING MESSAGE METHODS
	 **********************************/

	/**
	 * A new incoming message has been received.  Don't override this method.
	 */
	private function _onMessage( required message, required channel ) {
		onMessage( message.getData(), channel );
	}

	/**
	 * A new incoming message has been received.  Override this method.
	 */
	function onMessage( required message, required channel ) {
		// Override me
	}

	/**********************************
	 * OUTGOING MESSAGE METHODS
	 **********************************/

	/**
	 * Send a message to a specific channel
	 */
	function sendMessage( required message, required channel ) {
		println("sending message to specific channel: #message#");
		getWSHandler().sendMessage( channel, message );
	}

	/**
	 * Broadcast a message to all connected channels
	 */
	function broadcastMessage( required message ) {
		println("broadcasting message: #message#");
		getWSHandler().broadcastMessage( message );
	}

	/**********************************
	 * UTILITY METHODS
	 **********************************/

	 /**
	  * Get Undertow WebSocket handler from the underlying server
	  */
	private function getWSHandler() {
		if( serverType == "boxlang-miniserver" ) {
			var wsHandler = serverClass.getWebsocketHandler();
		} else {
			var wsHandler = serverClass.getCurrentExchange().getAttachment( SITE_DEPLOYMENT_KEY ).getWebsocketHandler();
		}
		if( isNull( wsHandler ) ) {
			throw( type="WebSocketHandlerNotFound", message="WebSocket handler not found" );
		}
		return wsHandler;
	}

	/**
	 * Shim for BoxLang's println()
	 */
	private function println( required message ) {
		systemOutput( message, true );
	}

	/**
	 * Shim for Lucee's systemOutput()
	 */
	private function systemOutput( required message ) {
		writedump( var=message.toString(), output="console" );
	}

	/**
	 * Detect if we're on CommandBox or the BoxLang Miniserver
	 */
	private function detectServerType() {
		try {
			variables.serverClass = createObject('java', 'runwar.Server')
			variables.SITE_DEPLOYMENT_KEY = createObject('java', 'runwar.undertow.SiteDeploymentManager' ).SITE_DEPLOYMENT_KEY;
			variables.WEBSOCKET_REQUEST_DETAILS = createObject('java', 'runwar.undertow.WebsocketReceiveListener' ).WEBSOCKET_REQUEST_DETAILS;
			return "runwar";
		} catch( any e ) {
			try {
				variables.serverClass = createObject('java', 'ortus.boxlang.web.MiniServer')
				variables.WEBSOCKET_REQUEST_DETAILS = createObject('java', 'ortus.boxlang.web.handlers.WebsocketReceiveListener' ).WEBSOCKET_REQUEST_DETAILS;
				return "boxlang-miniserver";
			} catch( any e) {
				throw( type="ServerTypeNotFound", message="This websocket library can only run in CommandBox or the BoxLang Miniserver." );
			}
		}
	}
	
}