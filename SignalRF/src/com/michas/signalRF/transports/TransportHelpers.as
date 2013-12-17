package com.michas.signalRF.transports
{
	import com.adobe.utils.StringUtil;
	import com.michas.async.TaskInterop;
	import com.michas.signalRF.IConnection;
	import com.michas.signalRF.PersistentResponse;
	import com.michas.signalRF.enums.ConnectionState;
	import com.michas.signalRF.tasks.TaskCommands;
	
	import mx.utils.ObjectUtil;
	import mx.utils.StringUtil;

	public class TransportHelpers
	{
		private static const _abortQueryString:String = "?transport={0}&connectionData={1}&connectionToken={2}";
		private static var _startedAbort:Boolean = false;
		private static var _transportName:Object;
		
		public function TransportHelpers()
		{
		}
		
		public static function createNegotiateUrl(connection:IConnection, connectionData:String):String{
			var negotiateUrl:String = connection.url + "negotiate";
			
			negotiateUrl += TransportHelpers.appendCustomQueryString(connection, negotiateUrl);
			
			var appender:String = '?';
			if (negotiateUrl.indexOf("?") > -1)
			{
				appender = '&';
			}
			
			negotiateUrl += appender + "clientProtocol=" + connection.protocol.toString();
			
			if (com.adobe.utils.StringUtil.stringHasValue(connectionData))
			{
				negotiateUrl += "&connectionData=" + encodeURIComponent(connectionData);
			}
			
			return negotiateUrl;
		}
		
		public static function appendCustomQueryString(connection:IConnection, baseUrl:String):String
		{
			if (connection == null)
			{
				throw new ArgumentError("connection");
			}
			
			if (baseUrl == null)
			{
				baseUrl = "";
			}
			
			var appender:String = "";
			var	customQuery:String = connection.queryString;
			var	qs:String = "";
			
			if (com.adobe.utils.StringUtil.stringHasValue(customQuery))
			{
				var firstChar:String = customQuery.substr(0,1);
				
				// If the custom query string already starts with an ampersand or question mark
				// then we dont have to use any appender, it can be empty.
				if (firstChar != '?' && firstChar != '&')
				{
					appender = "?";
					
					if (baseUrl.indexOf(appender) > -1)
					{
						appender = "&";
					}
				}
				
				qs += appender + customQuery;
			}
			
			return qs;
		}
		
		public static function abort(connection:IConnection, timeout:Number, connectionData:String ):void{
			if (!_startedAbort)
			{
				_startedAbort = true;
				
				var url:String = connection.url + "abort" + mx.utils.StringUtil.substitute(
					_abortQueryString,
					connection.transport.name,
					encodeURIComponent(connectionData),
					encodeURIComponent(connection.connectionToken));
				
				url += TransportHelpers.appendCustomQueryString(connection, url);
				
				TaskCommands.postDataToUrl(url, null, connection.version, connection.headers)
					.catchWith(function(fault:*):void
					{
						// If there's an error making an http request set the reset event
						TransportHelpers.completeAbort();
						connection.log("Abort Error: {0}", fault);
					});
				
				/*if (!_abortResetEvent.WaitOne(timeout))
				{
					connection.Trace(TraceLevels.Events, "Abort never fired");
				}*/
			}
		}
		
		public static function completeAbort():void{
			_startedAbort = true;
			//NOTE not sure what to do here, do we try abort again or what? the c# code calls a native framework function
		}
		
		public static function processResponse(connection:IConnection, response:String, outObject:Object /*shouldReconnect disconnected*/):void
		{
			if (connection == null)
			{
				throw new ArgumentError("connection");
			}
			
			connection.markLastMessage();
			
			outObject.shouldReconnect = false;
			outObject.disconnected = false;
			
			if (!com.adobe.utils.StringUtil.stringHasValue(response))
			{
				connection.log("no response");
				return;
			}
			
			try
			{
				var result:Object = connection.jsonSerializer.parse(response);
				
				var isEmpty:Boolean = true;
				for (var n:* in result) { isEmpty = false; break; }
				
				if (isEmpty)
				{
					//connection.log("empty");
					return;
				}
				
				if (result["I"] != null)
				{
					connection.onReceived(result);
					return;
				}
				
				outObject.shouldReconnect = Number(result["T"]) == 1;
				outObject.disconnected = Number(result["D"]) == 1;
				
				if (outObject.disconnected)
				{
					return;
				}
				
				updateGroups(connection, result["G"]);
				
				var messages:Array = result["M"] as Array;
				//connection.log("messages length {0}", messages.length);
				if (messages != null)
				{
					connection.messageId = result["C"];
					
					for each (var message:Object in messages)
					{
						connection.onReceived(message);
					}
					
					//TODO create the initialization listener for the first message on connect
					//tryInitialize(result, onInitialized);
				}
			}
			catch (ex:Error)
			{
				connection.onError(ex);
			}
		}
		
		private static function updateGroups(connection:IConnection, groupsToken:String):void
		{
			if (groupsToken != null)
			{
				connection.groupsToken = groupsToken;
			}
		}

		
		public static function verifyLastActive(connection:IConnection):Boolean {
			//connection.log("VerifyLastActive {0} - {1}", new Date().getTime() - connection.lastActiveAt, connection.reconnectWindow )
			if ((new Date().getTime() - connection.lastActiveAt >= connection.reconnectWindow) && connection.state == ConnectionState.CONNECTED) {
				connection.log("There has not been an active server connection for an extended period of time. Stopping connection.");
				connection.stop();
				return false;
			}
			
			return true;
		}
		
		public static function maximizePersistentResponse(minPersistentResponse:Object):PersistentResponse {
			var response:PersistentResponse = new PersistentResponse();
			
			response.messageId = minPersistentResponse.C;
			response.messages = minPersistentResponse.M;
			response.initialized = typeof (minPersistentResponse.S) !== "undefined" ? true : false;
			response.disconnect = typeof (minPersistentResponse.D) !== "undefined" ? true : false;
			response.shouldReconnect = typeof (minPersistentResponse.T) !== "undefined" ? true : false;
			response.longPollDelay = minPersistentResponse.L;
			response.groupsToken = minPersistentResponse.G;
			
			
			return response;
		}
		
		//THIS ONE IS MINE, NBOT SURE IF IT WILL BE USED
		public static function minimizePersistentResponse(maxPersistentResponse:PersistentResponse):Object {
			var response:Object = {
				C:maxPersistentResponse.messageId,
					M:maxPersistentResponse.messages,
					S:maxPersistentResponse.initialized==true ? 1 : 0,
					D:maxPersistentResponse.disconnect==true ? 1 : 0,
					T:maxPersistentResponse.shouldReconnect==true ? 1 : 0,
					L:maxPersistentResponse.longPollDelay,
					G:maxPersistentResponse.groupsToken
			};
			
			return response;
		}
	}
}