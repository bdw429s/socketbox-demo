<!DOCTYPE html>
<html lang="en-US">
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
		<main class="container">
		<h1>SocketBox Demo</h1>
		<p>
			This is a simple chat application that uses WebSockets to communicate with the server. It is built using CFML (running on BoxLang) and our new
			<a href="https://forgebox.io/view/socketbox">SocketBox library</a>.  SocketBox is a new feature built into CommandBox and the BoxLang MiniServer
			to be able to easily create WebSocket servers in CFML that work for Adobe ColdFusion, Lucee Server, or BoxLang!
		</p>

		<label for="name">Your Name:</label>
		<input type="text" id="name" name="name" size="10" value="User #randRange( 1000, 5000 )#" onChange="socket.send( 'user-rename: ' + this.value ); updateUsernameColor(); updateUsername(this.value);" /><br>
		<span id="users-online" title="">
		<strong>Users Online: &nbsp;&nbsp; <span id="users" style="font-size: 1.5em;">0</span></strong><br>
		<em>(Hover to see names)</em>
		</span>
		<br/>
		<br/>
		<div id="chat" class="chat"></div>
		<a href="##" style="float: right;" onclick="clearChat()">Clear Chat</a><BR>


		<form action="sender.cfm" method="post" onsubmit="return false;">
			<label for="message">Type a message to send to the chat room:</label>
			<input type="text" id="message" name="message" value="" size="50" />
			<input type="submit" value="Send" onClick="sendMessage()" />
		</form>
		</main>
		<script language="javascript">
			reconnecting = false;
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

			function connect() {
				socket = new WebSocket('#connectionAddress#');
				socket.onopen = function() {
					reconnecting = false;
					console.log('Connected to WebSocket server');
					socket.send( "new-user: " + document.getElementById('name').value );
					message = '<br><span style="color: grey;"><em>WebSocket connected.</em></span><br>';
					document.getElementById('chat').innerHTML += message;
					scrollChatToBottom();
				};

				socket.onmessage = function(event) {
					let message = event.data;
					console.log('Message from server:', message);
					if( message.indexOf('num-connections: ') == 0 ) {
						message = message.replace('num-connections: ', '');
						let parts = message.split(/;(.+)/); // Split only on the first semicolon
						document.getElementById('users').innerText = parts[0];
						let namesJSON = parts[1];
						// array of strings
						let names = JSON.parse(namesJSON);
						// Build HTML list of escaped user names from the array in names
						let userList = names.map(function(name) {
							return escapeHTML(name);
						}).join('\n');
						document.getElementById('users-online').title = userList;

					} else if( message.indexOf('new-message: ') == 0 ) {
						message = message.replace('new-message: ', '');
						// if message is "user name: actual message"
						// wrap bold around the user name and escape any HTML in the actual message
						if (message.indexOf(':') > 0) {
							let parts = message.split(/:(.+)/); // Split only on the first colon
							let username = parts[0];
							let userColor = getColorForUsername(username);
							let html = '<strong style="color:' + userColor + ';">' + escapeHTML(username) + ':</strong> ' + escapeHTML(parts[1]) + "<br>";
							document.getElementById('chat').innerHTML += html;
							scrollChatToBottom();
							addHistory(html);
						} else {
							// if message contains text "has joined" or "changed their name" then color grey
							if (message.indexOf('has joined') > 0 ||message.indexOf('has left') > 0 || message.indexOf('changed their name') > 0) {
								message = '<span style="color: grey;">' + escapeHTML(message) + '</span><br>';
							} else {
								message = '<b style="color: red;">' + escapeHTML(message) + "</b><br>";
							}
							document.getElementById('chat').innerHTML += message;
							scrollChatToBottom();
							// notifications
							addHistory(message);
						}
					}
				};

				socket.onclose = function(e) {
					if( !reconnecting ) {
						console.log('Socket is closed. Reconnect will be attempted in 1 second.', e.reason);
						message = '<span style="color: grey;"><em>WebSocket is closed. Reconnecting...</em></span>';
						document.getElementById('chat').innerHTML += message;
						scrollChatToBottom();
					} else {
						document.getElementById('chat').innerHTML += '.';
					}
					
					reconnecting = true;
					setTimeout(function() {
						connect();
					}, 1000);
				};

				socket.onerror = function(err) {
					console.error('Socket encountered error: ', err.message, 'Closing socket');
					ws.close();
				};
			}

			// Function to update the color of the username input
			function updateUsernameColor() {
				const usernameInput = document.getElementById('name');
				const username = usernameInput.value;
				const userColor = getColorForUsername(username);
				usernameInput.style.color = userColor;
			}

			// Function to scroll chat to the bottom
			function scrollChatToBottom() {
				const chat = document.getElementById('chat');
				chat.scrollTop = chat.scrollHeight;
			}

			let colors = [
				'##DB0538', // Red
				'##14960B', // Green
				'##1A6BB8', // Blue
				'##A822BF', // Pink
				'##C94A2A', // Orange
				'##0D948F', // Cyan
				'##4A13BF', // Purple
				'##AD8813', // Yellow
			];
			if (window.matchMedia('(prefers-color-scheme: dark)').matches) {
				// Array of easy-to-read primary colors
				colors = [
					'##FF5733', // Red
					'##33FF57', // Green
					'##3357FF', // Blue
					'##FF33A1', // Pink
					'##FF8C33', // Orange
					'##33FFF5', // Cyan
					'##8C33FF', // Purple
					'##FFD433', // Yellow
				];
			}

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

			// history
			function loadHistory(){
				if (!('history' in localStorage)) return;
				const hist = JSON.parse(localStorage.getItem("history"));
				hist.forEach((msg) => {
					document.getElementById('chat').innerHTML += msg;
				});
			}

			function addHistory(item){
				let hist = JSON.parse(localStorage.getItem("history")) || [];
				hist.push(item);
				if (hist.length > 99) hist.shift();
				localStorage.setItem("history", JSON.stringify(hist));
			}

			// username
			function getUsername(){
				if (!('username' in localStorage)) return;
				document.getElementById('name').value = localStorage.getItem('username');
				updateUsernameColor();
			}

			function updateUsername(username){
				localStorage.setItem('username', username);
			}

			// Function to clear the chat and local history
			function clearChat() {
				document.getElementById('chat').innerHTML = '';
				localStorage.removeItem('history');
			}

			connect();
			updateUsernameColor();
			loadHistory();
			getUsername()
		</script>
	</body>
</cfoutput>
</html>