package com.michas.signalRF
{
	import com.adobe.net.URI;
	import com.adobe.utils.StringUtil;
	import com.michas.async.CancelTokenSource;
	import com.michas.async.ITask;
	import com.michas.signalRF.enums.ConnectionState;
	import com.michas.signalRF.events.SignalRErrorEvent;
	import com.michas.signalRF.events.SignalREvent;
	import com.michas.signalRF.events.SignalRReceivedEvent;
	import com.michas.signalRF.events.SignalRStateChangedEvent;
	import com.michas.signalRF.http.IRequest;
	import com.michas.signalRF.tasks.MessageReceivedTask;
	import com.michas.signalRF.tasks.TaskCommands;
	import com.michas.signalRF.tasks.queue.TaskController;
	import com.michas.signalRF.transports.IClientTransport;
	import com.michas.signalRF.transports.TransportHelpers;
	import com.michas.signalRF.transports.websockets.WebSocketTransport;
	import com.michas.signalRF.utils.ICredentials;
	import com.michas.signalRF.utils.JSONWrapper;
	import com.michas.signalRF.utils.Resources;
	import com.michas.signalRF.utils.Version;
	
	import flash.events.EventDispatcher;
	import flash.globalization.DateTimeFormatter;
	import flash.globalization.DateTimeStyle;
	import flash.globalization.LocaleID;
	import flash.system.Capabilities;
	import flash.system.Security;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import mx.utils.StringUtil;
	
	
	[Event(name="signalR_onStart", type="com.michas.signalRF.events.SignalREvent")]
	[Event(name="signalR_onStarting", type="com.michas.signalRF.events.SignalREvent")]
	[Event(name="signalR_onReceived", type="com.michas.signalRF.events.SignalREvent")]
	[Event(name="signalR_onError", type="com.michas.signalRF.events.SignalREvent")]
	[Event(name="signalR_onConnectionSlow", type="com.michas.signalRF.events.SignalREvent")]
	[Event(name="signalR_onReconnecting", type="com.michas.signalRF.events.SignalREvent")]
	[Event(name="signalR_onReconnected", type="com.michas.signalRF.events.SignalREvent")]
	[Event(name="signalR_onStateChanged", type="com.michas.signalRF.events.SignalREvent")]
	[Event(name="signalR_onDisconnected", type="com.michas.signalRF.events.SignalREvent")]
	[Event(name="signalR_onClosed", type="com.michas.signalRF.events.SignalREvent")]
	[Event(name="signalR_connected", type="com.michas.signalRF.events.SignalREvent")]
	
	public class Connection extends EventDispatcher implements IConnection
	{
		/*
		 *  Properties 
		*/
		public function get dateFormatter():DateTimeFormatter{
			return _df;
		}
		
		private var _protocol:Version;
		public function get protocol():Version { return _protocol; }
		public function set protocol(value:Version):void
		{
			if (_protocol == value)
				return;
			_protocol = value;
		}
		
		private var _transportConnectTimeout:Number;
		public function get transportConnectTimeout():Number { return _transportConnectTimeout; }
		public function set transportConnectTimeout(value:Number):void
		{
			if (_transportConnectTimeout == value)
				return;
			_transportConnectTimeout = value;
		}
		
		private var _reconnectWindow:Number;
		public function get reconnectWindow():Number { return _reconnectWindow; }
		/**
		 * The amount of time in milliseconds that the client will continue to reconnect to the signalR server hub if the connection is lost before giving up and closing the connection. 
		 * @param value time in milliseconds
		 * 
		 */		
		public function set reconnectWindow(value:Number):void
		{
			if (_reconnectWindow == value)
				return;
			_reconnectWindow = value;
		}
		
		private var _keepAliveData:KeepAliveData;
		public function get keepAliveData():KeepAliveData { return _keepAliveData; }
		protected function set keepAliveData(value:KeepAliveData):void
		{
			if (_keepAliveData == value)
				return;
			_keepAliveData = value;
		}
		
		private var _messageId:String;
		public function get messageId():String { return _messageId; }
		public function set messageId(value:String):void
		{
			if (_messageId == value)
				return;
			_messageId = value;
		}
		
		private var _groupsToken:String;
		public function get groupsToken():String { return _groupsToken; }
		public function set groupsToken(value:String):void
		{
			if (_groupsToken == value)
				return;
			_groupsToken = value;
		}
		
		private var _items:Dictionary;
		public function get items():Dictionary { return _items; }
		
		private var _connectionId:String;
		public function get connectionId():String { return _connectionId; }
		
		private var _connectionToken:String;
		public function get connectionToken():String { return _connectionToken; }
		
		private var _url:URI;
		public function get url():URI { return _url; }		
		
		private var _queryString:String;
		public function get queryString():String { return _queryString; }
		
		private var _state:ConnectionState;
		public function get state():ConnectionState { return _state; }
		
		private var _transport:IClientTransport;
		public function get transport():IClientTransport { return _transport; }
		
		private var _lastMessageAt:Number;
		public function get lastMessageAt():Number { return _lastMessageAt; }
		
		private var _lastActiveAt:Number;
		public function get lastActiveAt():Number { return _lastActiveAt; }
		
		private var _headers:Dictionary;
		public function get headers():Dictionary { return _headers; }
		
		private var _receiveQueue:TaskController = new TaskController();
		
		private var _credentials:ICredentials;
		public function get credentials():ICredentials { return _credentials; }
		/**
		 * For basic http auth you should set the credentials. The auth header will be added to the calls to the signalR server.
		 * @param value a new ICredentials() object
		 * 
		 */		
		public function set credentials(value:ICredentials):void
		{
			if (_credentials == value)
				return;
			_credentials = value;
		}
	
		public function get jsonSerializer():JSONWrapper
		{
			return new JSONWrapper();
		}
		
		private var _monitor:HeartbeatMonitor;
		public function get monitor():HeartbeatMonitor{
			return _monitor;
		}
		
		/**
		 * Version and build as X.X.X.Y where the X's are in parity with the SignalR server version that is supported. The Y is the build number of the SignalRF Flex Client SWC. 
		 * @return Version and build as string
		 * The build number is updated automatically when performing an ant build.
		 */		
		public function get version():String {
			return LibVersion.VERSION;
		}
		
		/**
		 * By default this is trace for console debugging. You can override the normal trace by supplying a function to handle the output, i.e. for mobile debugging you might supply a function that writes the output to a text field in the UI. 
		 * @param f a function with the signature function(text:String):void
		 * The default tracing will give you a bit more information as some of the included frameworks/code sends debugging directly to trace bypassing the base SignalRF client code.
		 */		
		public function set logOutput(f:Function):void{
			_logOutput = f;
		}
		
		/*
		 * Private Properties 
		*/
		private var _df:DateTimeFormatter = new DateTimeFormatter(LocaleID.DEFAULT, DateTimeStyle.SHORT, DateTimeStyle.MEDIUM);
		private var _logging:Boolean = false;
		private var _disconnectTimeoutOperation:Function;
		private var _connectTask:ITask;
		private var _disconnectCts:CancelTokenSource;
		private var _connectionData:String;
		private var _disconnectTimeout:Number;
		private var _defaultAbortTimeout:Number = 30000;
		private var _logOutput:Function = trace; 
		
		
		public function Connection(){
		}
		/**
		 * Initialize a new SignalR connection for the given url 
		 * @param url The URL of the long polling endpoint
		 * @param qs [Optional] Custom querystring parameters to add to the connection URL.
		 * If an object, every non-function member will be added to the querystring.
		 * If a string, it's added to the QS as specified.
		 * @param logging [Optional] A flag indicating whether connection logging is enabled to the console. Defaults to false.
		 * 
		 */
		public function init(url:String, qs:String = null, logging:Boolean = false):void{
			
			if (url == null)
			{
				throw new ArgumentError("url");
			}
			
			if (url.indexOf("?") > -1)
			{
				throw new ArgumentError(Resources.error_UrlCantContainQueryStringDirectly, "url");
			}
			
			if (!com.adobe.utils.StringUtil.endsWith(url,"/"))
			{
				url += "/";
			}
			
			_url = new URI(url);
			_queryString = qs;
			_logging = logging;
			
			_disconnectTimeoutOperation = function():void{};
			_reconnectWindow = 0;
			
			_items = new Dictionary();
			changeState(null,ConnectionState.DISCONNECTED);
			//_state = ConnectionState.DISCONNECTED;
			/*TraceLevel = TraceLevels.All;
			TraceWriter = new DebugTextWriter();*/
			_headers = new Dictionary();
			_transportConnectTimeout = 0;
			
			Security.loadPolicyFile("http://"+_url.authority+"/crossdomain.xml");
			_protocol = new Version(1,3);
		}
		
		public function start():ITask{
			return startWithTransport(new WebSocketTransport());
		}
		
		public function startWithTransport(transport:IClientTransport):ITask
		{
			_lastMessageAt = new Date().getTime();
			_lastActiveAt = new Date().getTime();
			
			if (!changeState(ConnectionState.DISCONNECTED, ConnectionState.CONNECTING))
			{
				return _connectTask!=null ? _connectTask : TaskCommands.empty;
			}
			
			_disconnectCts = new CancelTokenSource();
			//_startTcs = new TaskCompletionSource<object>();
			//_receiveQueue = new TaskQueue(_startTcs.Task);
			//_lastQueuedReceiveTask =  TaskCommands.empty;
			
			_transport = new WebSocketTransport();
			
			_connectTask = negotiate(this);
			
			return _connectTask;
		}
		
		private function negotiate(connection:IConnection):ITask{
			
			_connectionData = onSending();
			
			return connection.transport.negotiate(connection, _connectionData)
				.continueWith(function(response:String):ITask{
					connection.log("NegotiationResponse {0}", response);
					var negotiationResponse:NegotiationResponse = new NegotiationResponse(response);
					
					_connectionId = negotiationResponse.connectionId;
					_connectionToken = negotiationResponse.connectionToken;
					_disconnectTimeout = negotiationResponse.disconnectTimeout * 1000;
					_transportConnectTimeout = negotiationResponse.transportConnectTimeout * 1000;
					
					// Default the beat interval to be 5 seconds in case keep alive is disabled.
					var beatInterval:Number = 5000;
					
					// If we have a keep alive
					if (negotiationResponse.keepAliveTimeout != null)
					{
						_keepAliveData = new KeepAliveData(negotiationResponse.keepAliveTimeout);
						//_keepAliveData.activated = true;
						//_keepAliveData.monitoring = true;
						//_keepAliveData.userNotified = false;
						
						_reconnectWindow = _disconnectTimeout + _keepAliveData.timeout;
						
						beatInterval = _keepAliveData.checkInterval;
					}
					else
					{
						_reconnectWindow = _disconnectTimeout;
					}
					//_reconnectWindow = 5000;
					_monitor = new HeartbeatMonitor(connection, beatInterval);
					
					return startTransport();
				})
				.unwrap()
				.catchWith(function(fault:*):void{
					connection.log(fault);
					connection.disconnect();
				});
		}
		
		private function startTransport():ITask
		{
			return _transport.start(this, _connectionData, _disconnectCts)
				.await(function():void{
					changeState(ConnectionState.CONNECTING, ConnectionState.CONNECTED);
					
					// Start the monitor to check for server activity
					_monitor.start();
				})
				.catchWith(function(fault:*):void{
					this.log(fault);
				});
				
				/*
				.RunSynchronously(() =>
					{
						// NOTE: We have tests that rely on this state change occuring *BEFORE* the start task is complete
						ChangeState(ConnectionState.Connecting, ConnectionState.Connected);
						
						// Now that we're connected complete the start task that the
						// receive queue is waiting on
						_startTcs.SetResult(null);
						
						// Start the monitor to check for server activity
						_monitor.Start();
					})
			// Don't return until the last receive has been processed to ensure messages/state sent in OnConnected
			// are processed prior to the Start() method task finishing
			.Then(() => _lastQueuedReceiveTask);
				*/
		}
		
		public function changeState(oldState:ConnectionState, newState:ConnectionState):Boolean
		{
			// If we're in the expected old state then change state and return true
			if (_state == oldState)
			{
				log("ChangeState({0}, {1})", oldState, newState);
				_state = newState;
				dispatchEvent(new SignalRStateChangedEvent(SignalREvent.STATE_CHANGED,oldState,newState));
				if(newState == ConnectionState.CONNECTED){
					dispatchEvent(new SignalREvent(SignalREvent.CONNECTED));
				}
				return true;
			}
			return false;
		}
		
		public function stop():void
		{
			//NOTE not sure what we are waiting for in c# so Im leaving is out
			// Wait for the connection to connect
			/*
			if (_connectTask != null)
			{
				try
				{
					_connectTask.wait(timeout);
				}
				catch (ex:Error)
				{
					log("Error: {0}", ex.message);
				}
			}
			*/
			
			//NOTE we dont have a queue implemented yet
			/*if (_receiveQueue != null)
			{
				// Close the receive queue so currently running receive callback finishes and no more are run.
				// We can't wait on the result of the drain because this method may be on the stack of the task returned (aka deadlock).
				_receiveQueue.Drain().Catch();
			}*/
			
			// This is racy since it's outside the _stateLock, but we are trying to avoid 30s deadlocks when calling _transport.Abort()
			if (_state == ConnectionState.DISCONNECTED)
			{
				log("Connection already disconnected");
				return;
			}
			
			log("Stop");
			
			//NOTE we dont have a monitor implemented
			// Dispose the heart beat monitor so we don't fire notifications when waiting to abort
			//_monitor.Dispose();
			_monitor.stop();
				
			_transport.abort(this, _defaultAbortTimeout, _connectionData);
			
			//this will wait for the transport to stop then call disconnect()
			_transport.stop(this).await(disconnect);
		}
		
		public function disconnect():void
		{
			// Do nothing if the connection is offline
			if (_state != ConnectionState.DISCONNECTED)
			{
				// Change state before doing anything else in case something later in the method throws
				_state = ConnectionState.DISCONNECTED;
				dispatchEvent(new SignalRStateChangedEvent(SignalREvent.STATE_CHANGED,null,ConnectionState.DISCONNECTED));
				
				log("Disconnected");
				dispatchEvent(new SignalREvent(SignalREvent.DISCONNECTED));
				//_disconnectTimeoutOperation;
				_disconnectCts.cancel();
				//_disconnectCts.dispose();
				
				//NOTE we dont implement a monitor yet
				if (_monitor != null)
				{
					_monitor.dispose();
				}
				
				if (_transport != null)
				{
					log("transport.dispose({0})", _connectionId);
					//_transport.dispose();
					switch(getQualifiedClassName(_transport)){
						case "com.michas.signalRF.transports.websockets::WebSocketTransport":
						_transport = new WebSocketTransport();
						break;
					}
				}
				
				log("Closed");
				
				// Clear the state for this connection
				_connectionId = null;
				_connectionToken = null;
				_groupsToken = null;
				_messageId = null;
				_connectionData = null;
				
				dispatchEvent(new SignalREvent(SignalREvent.CLOSED));
			}
		}
		
		public function send(data:Object):ITask
		{
			if(this.state == ConnectionState.CONNECTED){
				var jsonStr:String = JSON.stringify(data);
				
				log("SEND DATA: {0}", jsonStr);
				return transport.send(this, jsonStr, _connectionData);
			}else{
				if(this.state == ConnectionState.DISCONNECTED){
					throw new Error("You can't send data on a connection that is disconnected.")
				}
			}
			return TaskCommands.empty;
		}
		
		public function onSending():String{
			return null;
		}
		
		public function onReceived(data:Object):void
		{
			//some sort of queue action happens here and then onMessageReceive is called for the next que item
			//log("Queued new message task")
			_receiveQueue.addTask(new MessageReceivedTask(this,onMessageReceived,data));
		}
		
		public function onMessageReceived(message:Object):void{
			dispatchEvent(new SignalRReceivedEvent(SignalREvent.RECEIVED,message));
		}
		
		public function onError(ex:Object):void
		{
			dispatchEvent(new SignalRErrorEvent(SignalREvent.ERROR,ex));
		}
		
		public function onReconnecting():void
		{
			log("Reconnecting");
			dispatchEvent(new SignalREvent(SignalREvent.RECONNECTING));
		}
		
		public function onReconnected():void
		{
			log("Reconnected");
			changeState(ConnectionState.RECONNECTING, ConnectionState.CONNECTED);
			dispatchEvent(new SignalREvent(SignalREvent.RECONNECTED));
		}
		
		public function onConnectionSlow():void
		{
			log("Connection slow");
			dispatchEvent(new SignalREvent(SignalREvent.CONNECTION_SLOW));
		}
		
		public function onClosed():void{
			dispatchEvent(new SignalREvent(SignalREvent.CLOSED));
		}
		
		public function prepareRequest(request:IRequest):void
		{
			//NOTE we sort of do this inline with the TaskCommands, might not be needed
			request.userAgent = mx.utils.StringUtil.substitute("{0}/{1} ({2})","SignalR.Client.Flex",version, Capabilities.os);
			request.setRequestHeaders(_headers);
		}
		
		public function markLastMessage():void
		{
			_lastMessageAt = new Date().getTime();
		}
		
		public function markActive():Boolean
		{
			if (TransportHelpers.verifyLastActive(this)) {
				_lastActiveAt = new Date().getTime();
				return true;
			}
			
			return false;
		}
		
		public function enableReconnectTimeout():void{
			//check if connection is connected
			//check if _reconnectTimeoutId already set (meaning we already have a uint for the interval)
			
		}
		
		public function log(msg:String, ...args):void
		{
			if (_logging === false) {
				return;
			}
			var formattedMsg:String = mx.utils.StringUtil.substitute(msg,args);
			var m:String = "[" + _df.format(new Date()) + "] SignalR: " + formattedMsg;
			_logOutput(m);
		}
	}
}