component extends="modules.socketbox.models.WebSocketCore" {

	application.chatNames = application.chatNames ?: {};
	
	function onMessage( required message, required channel ) {
		println("new message: #message#");
		// re-broadcast the message
		if( message.startsWith( "new-user: " ) ) {
			var name = message.replace( "new-user: ", "" );
			application.chatNames[ channel.hashCode() ] = name;
			broadcastMessage( "new-message: " & name & " has joined the chat" );
		} else if( message.startsWith( "new-message: " ) ) {
			var message = message.replace( "new-message: ", "" );
			broadcastMessage( "new-message: " & getUserName( channel ) & ": " & message );
		} else if( message.startsWith("user-rename: ") ) {
			var newName = message.replace( "user-rename: ", "" );
			broadcastMessage( "new-message: " & getUserName( channel ) & " has changed their name to " & newName );
			application.chatNames[ channel.hashCode() ] = newName;
		}
	}

	function onConnect( required channel ) {
		super.onConnect( arguments.channel );
		updateUserCount();
	}

	function onClose( required channel ) {
		super.onClose( arguments.channel );
		broadcastMessage( "new-message: " & getUserName( channel ) & " has left the chat" );
		application.chatNames.delete( channel.hashCode() );
		updateUserCount();
	}

	function updateUserCount() {
		broadcastMessage( "num-connections: " & getAllConnections().len() );
	}

	function getUserName( required channel ) {
		return application.chatNames[ channel.hashCode() ] ?: "Unknown";
	}


}