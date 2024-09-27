<cfscript>
	ws = new WebSocket();
	//dump( ws.getAllConnections() )
	if( form.keyExists( 'message' ) ) {
		ws.broadcastMessage( "new-message: " & form.message );
	}
</cfscript>
<form action="sender.cfm" method="post">
	<input type="text" name="message" value="Hello, world!" />
	<input type="submit" value="Send Broadcast from Server side" />
</form>