package com.michas.signalRF.hubs
{
	import com.adobe.utils.DictionaryUtil;
	import com.adobe.utils.StringUtil;
	import com.michas.async.ITask;
	import com.michas.async.TaskEx;
	import com.michas.async.TaskInterop;
	import com.michas.async.TaskSource;
	import com.michas.signalRF.IHubProxy;
	import com.michas.signalRF.enums.ConnectionState;
	import com.michas.signalRF.interfaces.IDisposable;
	import com.michas.signalRF.tasks.TaskCommands;
	
	import flash.errors.IllegalOperationError;
	import flash.utils.Dictionary;
	
	import mx.utils.ObjectUtil;
	
	import avmplus.getQualifiedClassName;
	
	public class HubProxy implements IHubProxy
	{
		
		private var _state:Dictionary;
		private var _connection:IHubConnection;
		private var _hubName:String;
		private var _subscriptions:Dictionary;
		
		public function HubProxy(hubConnection:IHubConnection, hubName:String)
		{
			_connection = hubConnection;
			_hubName = hubName;
			_state = new Dictionary();
			_subscriptions = new Dictionary();
		}
		
		public function setState(name:String, value:String):void
		{
			_state[name] = value;
		}
		
		public function getState(name:String):String
		{
			return _state[name];
		}
		
		public function invoke(method:String, ...args):ITask
		{
			return invoke$T.apply(null,[method,Object,false].concat(args));
		}
		
		public function invoke$T(method:String, $T:Class, returnsCollection:Boolean = false, ...args):ITask{
			
			if(this._connection.state != ConnectionState.CONNECTED){
				return TaskCommands.empty;
			}
			if (method == null)
			{
				throw new ArgumentError("method");
			}
			
			if (args == null)
			{
				throw new ArgumentError("args");
			}
			
			var tokenifiedArguments:Array = new Array();
			for (var i:int = 0; i < args.length; i++)
			{
				//tokenifiedArguments.push(_connection.jsonSerializer.stringify(args[i]));
				tokenifiedArguments.push(args[i]);
			}
			
			var tcs:TaskSource = new TaskSource();
			
			var callbackId:String = _connection.registerCallback(
				function(result:HubResult):ITask{
				
					if (result != null)
					{
						if (result.error != null)
						{
							if (result.isHubException)
							{
								// A HubException was thrown
								//tcs.TrySetException(new HubException(result.Error, result.ErrorData));
								tcs.trySetFault(new HubException(result.error,result.errorData));
							}
							else
							{
								//tcs.TrySetException(new InvalidOperationException(result.Error));
								tcs.trySetFault(new IllegalOperationError(result.error));
							}
						}
						else
						{
							try
							{
								if (result.state != null)
								{
									for each (var key:Object in result.state)
									{
										setState(key,result.state[key]);
									}
								}
								
								if (result.result != null)
								{
									//tcs.TrySetResult(result.Result.ToObject<T>(JsonSerializer));
									try{
										
										if(getQualifiedClassName($T)!="Object"){
											var obj:* = new $T()
											obj.parse(result.result);
											tcs.trySetResult(obj);
										}else{
											tcs.trySetResult(result.result);
										}
									}catch(err:Error){
										throw new Error(err.message + "\nError SignalR: $T must be a class that extends SignalRObject.");
									}
									
								}
								else
								{
									//tcs.trySetResult(default(T));
									tcs.trySetResult(new $T());
								}
							}
							catch (ex:Error)
							{
								// If we failed to set the result for some reason or to update
								// state then just fail the tcs.
								//tcs.TrySetUnwrappedException(ex);
								tcs.trySetFault(ex);
							}
						}
					}
					else
					{
						//tcs.TrySetCanceled();
						tcs.trySetCancelled();
					}
					return tcs;
				});
			
			var hubData:HubInvocation = new HubInvocation();
			
			hubData.hub = _hubName;
			hubData.method = method;
			hubData.args = tokenifiedArguments;
			hubData.callbackId = callbackId;
			
			
			if (DictionaryUtil.getKeys(_state).length != 0)
			{
				hubData.state = _state;
			}
			
			var value:Object = hubData.minify();
			
			//return _connection.send(value)
				/*.continueWith(
				function(result:*):void
				{
					if(result!=null){
						var task:ITask = new TaskSource();
						if (task.isCancelled())
						{
							_connection.removeCallback(callbackId);
							tcs.trySetCancelled();
						}
						else if (task.isFaulted())
						{
							_connection.removeCallback(callbackId);
							//tcs.TrySetUnwrappedException(task.Exception);
							tcs.trySetFault(task.fault());
						}
					}
					
				})
				.catchWith(function(error:*):void{
					trace(error);
				});*/
				
				//TaskContinuationOptions.NotOnRanToCompletion);
			_connection.send(value);
			return tcs;
		}
		

		public function subscribe(eventName:String):Subscription
		{
			if (eventName == null)
			{
				throw new ArgumentError("eventName");
			}
			
			var subscription:Subscription;
			if (_subscriptions[eventName]==null)
			{
				subscription = new Subscription();
				_subscriptions[eventName] = subscription;
			}else{
				subscription = _subscriptions[eventName];
			}
			
			return subscription;
		}
		
		public function invokeEvent(eventName:String, args:Array):void
		{
			var subscription:Subscription;
			if (_subscriptions[eventName]!=null)
			{
				subscription = _subscriptions[eventName];
				
				subscription.onReceived(args);
			}
		}
		
		/// <summary>
		/// Registers for an event with the specified name and callback
		/// </summary>
		/// <param name="proxy">The <see cref="IHubProxy"/>.</param>
		/// <param name="eventName">The name of the event.</param>
		/// <param name="onData">The callback</param>
		/// <returns>An <see cref="IDisposable"/> that represents this subscription.</returns>
		public function on(eventName:String, $T:Class ,onData:Function):void
		{
			var proxy:HubProxy = this;
			
			if (!StringUtil.stringHasValue(eventName))
			{
				throw new ArgumentError("eventName");
			}
			
			if (onData == null)
			{
				throw new ArgumentError("onData");
			}
			
			var subscription:Subscription = proxy.subscribe(eventName);
			
			//Not sure what this does yet
			/*Action<IList<JToken>> handler = args =>
				{
					ExecuteCallback(eventName, args.Count, 0, onData);
				};*/
			subscription.$T = $T;
			subscription.received = onData;
			
			//return subscription;
		}
		
		public function off(eventName:String):void{
			if(_subscriptions[eventName]!=null){
				delete _subscriptions[eventName];
			}
		}
	}
}