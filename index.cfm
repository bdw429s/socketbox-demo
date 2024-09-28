<!DOCTYPE html>
<html>
<head>
	<title>SocketBox Demo</title>
	<link
  		rel="stylesheet"
  		href="https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.min.css"
	>
	<link rel="stylesheet" href="/resources/styles.css">
</head>
<body>
<cfoutput>
	<body>
		<main class="container-fluid">
		<h1>SocketBox Demo</h1>
		<p>
			This is a simple chat application that uses WebSockets to communicate with the server. It is built using CFML (running on BoxLang) and our new 
			<a href="https://forgebox.io/view/socketbox">SocketBox library</a>.  SocketBox is a new feature built into CommandBox and the BoxLang MiniServer 
			to be able to easily create WebSocket servers in CFML that work for Adobe ColdFusion, Lucee Server, or BoxLang!  
		</p>
		

		<label for="name">Your Name:</label> 
		<input type="text" id="name" name="name" size="10" value="User #randRange( 1000, 5000 )#" onChange="socket.send( 'user-rename: ' + this.value )" /><br>
		<strong>Users Online:</strong> <span id="users">0</span><br>
		<br>
		<label for="chat" class="sr-only">chat:</label>
		<div id="chat" style="width: 100%; height: 15em; overflow-y: scroll; border: 1px solid ##ccc;"></div>
		<br>
		<br>
		Type a message to send to the chat room:<br>
		<form action="sender.cfm" method="post" onsubmit="return false;">
			<input type="text" id="message" name="message" value="" size="50" />
			<input type="submit" value="Send" onClick="sendMessage()" />
		</form>
		</main>
		<script language="javascript">
			function sendMessage() {
				el = document.getElementById('message');
				if( el.value.trim() == '' ) return;
				socket.send( 'new-message: ' + el.value );
				el.value = '';
			}
			// Create a new WebSocket connection
			<cfscript>
				connectionAddress = '://#cgi.server_name#'
				if( cgi.https == true || cgi.https == 'on' ) {
					connectionAddress = 'wss' & connectionAddress;
				} else if( (getHTTPRequestData().headers['x-forwarded-proto'] ?: '') == 'https' ) {
					connectionAddress = 'wss' & connectionAddress;
				} else {
					connectionAddress = 'ws' & connectionAddress & ":" & cgi.SERVER_PORT;
				}
				connectionAddress = connectionAddress & '/ws';
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
					message = message.replace('new-message: ', '');
					// if message is "user name: actual message"
					// wrap bold around the user name and escape any HTML in the actual message
					if (message.indexOf(':') > 0) {
						let parts = message.split(/:(.+)/); // Split only on the first colon
						let username = parts[0];
						let userColor = getColorForUsername(username);
						document.getElementById('chat').innerHTML += '<strong style="color:' + userColor + ';">' + escapeHTML(username) + ':</strong> ' + escapeHTML(parts[1]) + "<br>";
						scrollChatToBottom(); 
					} else {
						// if message contains text "has joined" or "changed their name" then color grey
						if (message.indexOf('has joined') > 0 || message.indexOf('changed their name') > 0) {
							message = '<span style="color: grey;">' + escapeHTML(message) + '</span><br>';
						} else {
							message = escapeHTML(message) + "<br>";
						}
						document.getElementById('chat').innerHTML += message;
						scrollChatToBottom(); 

					}
				}
			});

			// Function to scroll chat to the bottom
			function scrollChatToBottom() {
				const chat = document.getElementById('chat');
				chat.scrollTop = chat.scrollHeight;
			}

			// Array of easy-to-read primary colors
			const colors = [
				'##FF5733', // Red
				'##33FF57', // Green
				'##3357FF', // Blue
				'##FF33A1', // Pink
				'##FF8C33', // Orange
				'##33FFF5', // Cyan
				'##8C33FF', // Purple
				'##FFD433', // Yellow
			];

			// Function to hash the username
			function hashUsername(username) {
				let hash = 0;
				for (let i = 0; i < username.length; i++) {
					hash = username.charCodeAt(i) + ((hash << 5) - hash);
				}
				return hash;
			}
			
			// Function to get a color based on the username
			function getColorForUsername(username) {
				const hash = hashUsername(username);
				const index = Math.abs(hash) % colors.length;
				return colors[index];
			}

			// Function to escape HTML
			function escapeHTML(str) {
				return str.replace(/&/g, '&amp;')
						.replace(/</g, '&lt;')
						.replace(/>/g, '&gt;')
						.replace(/"/g, '&quot;')
						.replace(/'/g, '&##039;');
			}


			// Event listener for connection errors
			socket.addEventListener('error', function (event) {
				console.error('WebSocket error:', event);
			});
		</script>
	</body>
</cfoutput>
</html>