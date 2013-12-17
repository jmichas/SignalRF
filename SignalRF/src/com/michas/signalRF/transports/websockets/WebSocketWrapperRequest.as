package com.michas.signalRF.transports.websockets
{
	import com.adobe.utils.DictionaryUtil;
	import com.michas.signalRF.IConnection;
	import com.michas.signalRF.http.IRequest;
	import com.worlize.websocket.WebSocket;
	
	import flash.utils.Dictionary;
	
	public class WebSocketWrapperRequest implements IRequest
	{
		private var _clientWebSocket:WebSocket;
		private var _connection:IConnection;
		
		public function WebSocketWrapperRequest(clientWebSocket:WebSocket, connection:IConnection)
		{
			_clientWebSocket = clientWebSocket;
			_connection = connection;
			prepareRequest();
			
			
		}
		
		private function prepareRequest():void
		{
			/*if (_connection.certificates != null)
			{
			addClientCerts(_connection.Certificates);
			}
			
			if (_connection.cookieContainer != null)
			{
			cookieContainer = _connection.cookieContainer;
			}
			*/
			if (_connection.credentials != null)
			{
				_clientWebSocket.setAuthorizationHeader(_connection.credentials.username, _connection.credentials.password);
			}
			/*
			if (_connection.proxy != null)
			{
			proxy = _connection.proxy;
			}*/
		}
		
		private var _userAgent:String;
		public function get userAgent():String
		{
			return _userAgent;
		}
		
		public function set userAgent(agent:String):void
		{
			_userAgent = agent;
		}
		
		private var _accept:String;
		public function get accept():String
		{
			return _accept;
		}
		
		public function set accept(v:String):void
		{
			_accept = v;
		}
		
		public function abort():void
		{
		}
		
		public function setRequestHeaders(headers:Dictionary):void
		{
			var keys:Array = DictionaryUtil.getKeys(headers);
			var values:Array = DictionaryUtil.getValues(headers);
			for(var x:int = 0;x<keys.length;x++){
				_clientWebSocket.headers[keys[x]] = values[x];
			}
		}
	}
}