package com.michas.signalRF.transports.websockets
{
	import com.adobe.net.URI;
	import com.adobe.utils.StringUtil;
	import com.hurlant.crypto.symmetric.NullPad;
	import com.michas.async.CancelTokenSource;
	import com.michas.async.ITask;
	import com.michas.async.TaskInterop;
	import com.michas.signalRF.IConnection;
	import com.michas.signalRF.KeepAliveData;
	import com.michas.signalRF.PersistentResponse;
	import com.michas.signalRF.enums.ConnectionState;
	import com.michas.signalRF.tasks.TaskCommands;
	import com.michas.signalRF.transports.IClientTransport;
	import com.michas.signalRF.transports.TransportHelpers;
	import com.worlize.websocket.WebSocket;
	import com.worlize.websocket.WebSocketErrorEvent;
	import com.worlize.websocket.WebSocketEvent;
	import com.worlize.websocket.WebSocketMessage;
	
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.system.Capabilities;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	public class WebSocketTransport implements IClientTransport
	{
		private var _websocket:WebSocket;
		private var _firstMessage:PersistentResponse;
		private var _connection:IConnection;
		private var _disconnectToken:CancelTokenSource;
		private var _connectionData:String;
		private var _reconnectTimer:Timer;
		private var _reconnectTimeoutTimer:Timer;
		private var _doReconnect:Boolean = false;
		
		public function WebSocketTransport()
		{
			
		}
		
		public function get name():String
		{
			return "webSockets";
		}
		
		public function get supportsKeepAlive():Boolean
		{
			return true;
		}
		
		public function negotiate(connection:IConnection, connectionData:String):ITask
		{
			var url:String = TransportHelpers.createNegotiateUrl(connection,connectionData);
			connection.log("Negotiating Connection to {0}", url);
			return TaskInterop.loadText(url, 10000 ,connection.headers);
		}
		
		public function start(connection:IConnection, connectionData:String, disconnectToken:CancelTokenSource):ITask
		{
			if (connection == null)
			{
				throw new ArgumentError("connection");
			}
			
			//TODO: start transport connection timeout timer and cancel the connection attempt if the timeout expires
			// maybe dont need this, not sure yet. Negotiation times out gracefully, websocket should timeout too.
			// not sure how to test because the server would need to fail after negotiation
			_connection = connection;
			_connectionData = connectionData;
			_disconnectToken = disconnectToken;
			
			return performConnect();
		}
		
		private function performConnect(reconnecting:Boolean = false):ITask{
			
			//PerformConnect
			var _uri:URI = _connection.url;
			
			var wsUrl:String = _uri.scheme.toLowerCase() == "https" ? "wss://" : "ws://";
			wsUrl += _uri.authority + _uri.path + (reconnecting ? "reconnect" : "connect") + "?";
			wsUrl += "transport=webSockets";
			wsUrl += "&connectionToken=" + encodeURIComponent(_connection.connectionToken);
			if(StringUtil.stringHasValue(_connectionData)){
				wsUrl += "&connectionData=" + encodeURIComponent(_connectionData);
			}
			if(StringUtil.stringHasValue(_connection.groupsToken)){
				wsUrl += "&groupsToken=" + encodeURIComponent(_connection.groupsToken);
			}
			wsUrl += "&tid=" + Math.random();
			
			_websocket = new WebSocket(wsUrl,"*",null,_connection.keepAliveData.timeout/4);
			addEventListeners();
			_websocket.debug = Capabilities.isDebugger;
			
			_connection.prepareRequest(new WebSocketWrapperRequest(_websocket, _connection));
			//-------
			
			return TaskCommands.connectWebSocket(_websocket);
			
		}
		
		public function stop(connection:IConnection):ITask{
			
			if(_websocket!=null){
				
				return TaskCommands.closeWebSocket(_websocket).await(function():void{
					_websocket = null;
				});
			}
			return TaskCommands.empty;
		}
		
		public function send(connection:IConnection, data:String, connectionData:String):ITask
		{
			return TaskCommands.sendDataToWebSocket(_websocket,data);
		}
		
		public function abort(connection:IConnection, timeout:Number, connectionData:String):void
		{
			TransportHelpers.abort(connection,timeout,connectionData);
		}
		
		public function lostConnection(connection:IConnection):void
		{
			/*
			when lost connection is called we should start the reconnection mode
			we need to:
			*/
			connection.monitor.stop();
			//-stop listening to messages
			_websocket.removeEventListener(WebSocketEvent.MESSAGE, listenToMessages);
			//-close/disconnect socket
			_websocket.close(false);
			
			//-change state to reconnecting
			_connection.changeState(ConnectionState.CONNECTED, ConnectionState.RECONNECTING);
			
			//-start a timer that will timeout after the reconnectwindow closes
			_reconnectTimeoutTimer = new Timer(_connection.reconnectWindow, 1);
			_reconnectTimeoutTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function timeout(e:TimerEvent):void{
				//	= once that happens we should do a disconnect and or stop so that the closed event is raised and the state changes
				_doReconnect = false;
				if(_reconnectTimer!=null){
					_reconnectTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, tryReconnect);
					_reconnectTimer.stop();
					_reconnectTimer = null;
				}
				_reconnectTimeoutTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,timeout);
				_reconnectTimeoutTimer.stop();
				_reconnectTimeoutTimer = null;
				 stop(_connection);
				_connection.disconnect();
			});
			
			_doReconnect = true; //this is set so that after a reconnectTimeout we can effectively cancel the reconnect loop by setting it to false;
			_reconnectTimeoutTimer.start();
			tryReconnect(null);
			_connection.onReconnecting();
			
		}
		
		protected function tryReconnect(event:TimerEvent):void
		{
			_connection.markActive();
			_connection.log("Attempting reconnect...");
			performConnect(true).continueWith(function(result:*):void{
				_connection.log("Reconnect Complete Called");
				//kill timers for reconnect
				_reconnectTimeoutTimer.stop();
				_reconnectTimeoutTimer = null;
				
				//change state to connected I think or call onReconnected in connection
				_connection.monitor.start();
				_connection.onReconnected();
			})
			.catchWith(function(fault:*):void{
				//if the reconnect failed we should try again in 2 seconds if the reconnectWindow is still open
				if(_doReconnect){
					_connection.log("Reconnect Failed:" + fault);
					//_websocket.close(false);
					_websocket = null;
					
					_reconnectTimer = new Timer(_connection.keepAliveData.timeout/4,1);
					_reconnectTimer.addEventListener(TimerEvent.TIMER_COMPLETE, tryReconnect);
					_reconnectTimer.start();
				}
			});
		}
		
		private function addEventListeners():void{
			/*_websocket.addEventListener(WebSocketEvent.OPEN,function(e:WebSocketEvent):void{
			trace("WebSocketEvent.OPEN")
			trace(e.message,e.frame)
			});*/
			
			_websocket.addEventListener(WebSocketEvent.FRAME,function(e:WebSocketEvent):void{
				trace("WebSocketEvent.FRAME")
				trace(e.frame)
			});
			
			_websocket.addEventListener(WebSocketEvent.CLOSED,function(e:WebSocketEvent):void{
				trace("WebSocketEvent.CLOSED")
			});
			
			_websocket.addEventListener(WebSocketErrorEvent.ABNORMAL_CLOSE,function(e:WebSocketErrorEvent):void{
				trace("WebSocketErrorEvent.ABNORMAL_CLOSE")
				trace(e.text)
			});
			
			_websocket.addEventListener(WebSocketEvent.MESSAGE, listenToMessages);
			
			_websocket.addEventListener(WebSocketEvent.PING,function(e:WebSocketEvent):void{
				trace("WebSocketEvent.PING")
				trace(e)
			});
			
			_websocket.addEventListener(WebSocketEvent.PONG,function(e:WebSocketEvent):void{
				trace("WebSocketEvent.PONG")
				trace(e)
			});
			
			/*_websocket.addEventListener(WebSocketErrorEvent.CONNECTION_FAIL, function(e:WebSocketErrorEvent):void{
			trace("WebSocketErrorEvent.CONNECTION_FAIL")
			trace(e.text);
			});*/
			
			/*_websocket.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void{
				trace("_websocket IOErrorEvent.IO_ERROR")
				trace(e.text);
			});*/
		}
		
		protected function listenToMessages(e:WebSocketEvent):void{
			//trace("WebSocketEvent.MESSAGE")
			//connection.log(e.message.utf8Data);
			if (e.message.type === WebSocketMessage.TYPE_UTF8){
				
				_connection.log("WebSocketEvent.MESSAGE {0}", e.message.utf8Data);
				
				var outObject:Object = {shouldReconnect:false, disconnected:false};
				TransportHelpers.processResponse(_connection,
					e.message.utf8Data,
					outObject);
				
				if (outObject.disconnected && !_disconnectToken.isCancelled())
				{
					_connection.disconnect();
				}
			}
			
			//trace(e.message)
			/*if (e.message.type === WebSocketMessage.TYPE_UTF8) {
			trace(connection.dateFormatter.format(new Date()), e.message.utf8Data);
			if(e.message.utf8Data.length>3){
			if(_firstMessage == null){
			_firstMessage = TransportHelpers.maximizePersistentResponse(JSON.parse(e.message.utf8Data));
			trace(JSON.stringify(_firstMessage));
			}
			}
			}
			else if (e.message.type === WebSocketMessage.TYPE_BINARY) {
			trace("Got binary message of length " + e.message.binaryData.length);
			}*/
		}
	}
}