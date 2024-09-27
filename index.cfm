<cfoutput>
	<h1>SocketBox Demo</h1>
	<p>
		This is a simple chat application that uses WebSockets to communicate with the server. It is built using CFML (running on BoxLang) and our new 
		<a href="https://forgebox.io/view/socketbox">SocketBox library</a>.  SocketBox is a new feature built into CommandBox and the BoxLang MiniServer 
		to be able to easily create WebSocket servers in CFML that work for Adobe ColdFusion, Lucee Server, or BoxLang!  
	</p>
	<script language="javascript">
		// Create a new WebSocket connection
		<cfscript>
			connectionAddress = '://#cgi.server_name#:#cgi.SERVER_PORT#/ws'
			if( cgi.https == true || cgi.https == 'on' ) {
				connectionAddress = 'wss' & connectionAddress;
			} else if( (getHTTPRequestData().headers['x-forwarded-proto'] ?: '') == 'https' ) {
				connectionAddress = 'wss' & connectionAddress;
			} else {
				connectionAddress = 'ws' & connectionAddress;
			}
		</cfscript>
		const socket = new WebSocket('#connectionAddress#');

		// Event listener for when the connection is open
		socket.addEventListener('open', function (event) {
			console.log('Connected to WebSocket server');
			socket.send( "new-user: " + document.getElementById('name').value );
		});

		// Event listener for receiving messages
		socket.addEventListener('message', function (event) {
			let message = event.data;
			console.log('Message from server:', message);
			if( message.indexOf('num-connections: ') == 0 ) {
				document.getElementById('users').innerText = message.replace('num-connections: ', '');
			} else if( message.indexOf('new-message: ') == 0 ) {
				document.getElementById('chat').value += message.replace('new-message: ', '') + "\n";
			}
		});

		// Event listener for connection errors
		socket.addEventListener('error', function (event) {
			console.error('WebSocket error:', event);
		});
	</script>

	Your Name: <input type="text" id="name" name="name" size="10" value="User #randRange( 1000, 5000 )#" onChange="socket.send( 'user-rename: ' + this.value )" /><br>
	Users Online: <span id="users">0</span><br>
	<br>
	<textarea id="chat" rows="15" cols="100"></textarea>
	<br>
	<br>
	Type a message to send to the chat room:<br>
	<form action="sender.cfm" method="post" onsubmit="return false;">
		<input type="text" id="message" name="message" value="" size="50" />
		<input type="submit" value="Send" onClick="socket.send( 'new-message: ' + document.getElementById('message').value )" />
	</form>

</cfoutput>