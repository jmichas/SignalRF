package com.michas.signalRF
{
	
	import com.adobe.utils.DateUtil;
	import com.adobe.utils.DictionaryUtil;
	import com.michas.signalRF.enums.ConnectionState;
	import com.michas.signalRF.hubs.HubInvocation;
	import com.michas.signalRF.hubs.HubProxy;
	import com.michas.signalRF.hubs.HubResult;
	import com.michas.signalRF.hubs.IHubConnection;
	import com.michas.signalRF.utils.Resources;
	
	import flash.utils.Dictionary;
	
	/**
	 * [Complete]
	 * Create a hub connection object
	 * This is the basis for the communication with the signalR server endpoint. 
	 * @author jmichas
	 * 
	 */	
	public class HubConnection extends Connection implements IHubConnection
	{
		Dictionary.prototype.toJSON = function(k:*):* { 
			//trace("prototype.toJSON() called.", k);
			var keys:Array = DictionaryUtil.getKeys(this);
			//var a:Array = new Array();
			var obj:Object = {};
			for(var x:int=0;x<keys.length;x++){
				
				obj[keys[x]] = this[keys[x]];
				//a.push(obj);
			}
			
			return obj;
		}
		Date.prototype.toJSON = function(k:*):*{
			var c:String = DateUtil.toW3CDTF(this);
			return c;
		}
			
		/**
		 * Dictionary of HubProxies.
		 * <hubName, HubProxy>
		 */		
		private var _hubs:Dictionary = new Dictionary();
		private var _callbacks:Dictionary = new Dictionary();
		private var _callbackId:int = 0;
		
		
		public function HubConnection()
		{
			super();
		}
		
		public override function onReconnecting():void{
			clearInvocationCallbacks(Resources.message_Reconnecting);
			super.onReconnecting();
		}
		
		/**
		 * 
		 * @param message JSON Object
		 * 
		 */		
		public override function onMessageReceived(message:Object):void{
			
			if (message.I != null)
			{
				var result:HubResult = new HubResult(message);
				var callback:Function;
				//Action<HubResult> callback;
				
				
				if (_callbacks[result.id]!=null)
				{
					callback = _callbacks[result.id];
					
					delete _callbacks[result.id];
				}
				else
				{
					log("Callback with id {0} not found!", result.id);
				}
			
				
				if (callback != null)
				{
					callback(result);
				}
			}
			else
			{
				var invocation:HubInvocation = new HubInvocation(message);
				var hubProxy:HubProxy;
				
				if (_hubs[invocation.hub]!=null)
				{
					hubProxy = _hubs[invocation.hub];
					if (invocation.state != null)
					{
						for each (var key:Object in invocation.state)
						{
							hubProxy[key] = invocation.state[key];
						}
					}
					
					hubProxy.invokeEvent(invocation.method, invocation.args);
				}
			}
			super.onMessageReceived(message);
		}
		
		public override function onSending():String{
			
			//This is for the connectionData. It should be a JSON object of subscriptions
			
			var hubReg:Array = new Array();
			var keys:Array = DictionaryUtil.getKeys(_hubs);
			for each(var key:String in keys){
				var regObj:Object = new Object();
				regObj.name = key;
				hubReg.push(regObj);
			}
			
			return JSON.stringify(hubReg);
		}
		
		public override function onClosed():void{
			clearInvocationCallbacks(Resources.message_ConnectionClosed);
			super.onClosed();
		}
		
		/**
		 * Creates a new HubProxy and adds it to the collection of proxies
		 * @param hubName The name of the hub to create.
		 * @return new HubProxy
		 * 
		 */		
		public function createHubProxy(hubName:String):IHubProxy{
			if (state != ConnectionState.DISCONNECTED)
			{
				throw new Error(Resources.error_ProxiesCannotBeAddedConnectionStarted);
			}
			
			var hubProxy:HubProxy;
			
			if (_hubs[hubName]==null)
			{
				hubProxy = new HubProxy(this, hubName);
				_hubs[hubName] = hubProxy;
			}else{
				hubProxy = _hubs[hubName];
			}
			return hubProxy;
		}
		
		public function registerCallback(callback:Function):String
		{
			var id:String = _callbackId.toString();
			_callbacks[id] = callback;
			_callbackId++;
			return id;
		}
		
		public function removeCallback(callbackId:String):void
		{
			delete _callbacks[callbackId];
		}
		
		
		private function clearInvocationCallbacks(error:String):void{
			var result:HubResult = new HubResult();
			result.error = error;
			
			for each (var value:Object in _callbacks)
			{
				(value as Function)(result);
			}
			
			for each(var key:Object in _callbacks){
				delete _callbacks[key];
			}
		}
	}
}