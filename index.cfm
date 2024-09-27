<cfoutput>
	<h1>Web Socket test</h1>
	<script language="javascript">
		// Create a new WebSocket connection
		const socket = new WebSocket('ws://#cgi.server_name#:#cgi.SERVER_PORT#/ws');

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

	Your Name: <input type="text" id="name" name="name" value="User #randRange( 1000, 5000 )#" onChange="socket.send( 'user-rename: ' + this.value )" /><br>
	Users Online: <span id="users">0</span><br>
	<br>
	<textarea id="chat" rows="15" cols="100"></textarea>
	<br>

	<form action="sender.cfm" method="post" onsubmit="return false;">
		<input type="text" id="message" name="message" value="" />
		<input type="submit" value="Send" onClick="socket.send( 'new-message: ' + document.getElementById('message').value )" />
	</form>

</cfoutput>