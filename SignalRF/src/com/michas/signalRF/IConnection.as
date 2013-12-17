package com.michas.signalRF
{
	import com.adobe.net.URI;
	import com.michas.async.ITask;
	import com.michas.signalRF.enums.ConnectionState;
	import com.michas.signalRF.http.IRequest;
	import com.michas.signalRF.transports.IClientTransport;
	import com.michas.signalRF.utils.ICredentials;
	import com.michas.signalRF.utils.JSONWrapper;
	import com.michas.signalRF.utils.Version;
	
	import flash.events.IEventDispatcher;
	import flash.globalization.DateTimeFormatter;
	import flash.utils.Dictionary;
	
	public interface IConnection extends IEventDispatcher
	{
		
		function get dateFormatter():DateTimeFormatter;
		
		function get protocol():Version;
		function set protocol(v:Version):void;
		function get transportConnectTimeout():Number;
		function set transportConnectTimeout(v:Number):void;
		function get reconnectWindow():Number;
		function set reconnectWindow(v:Number):void;
		function get keepAliveData():KeepAliveData;
		//function set keepAliveData(v:KeepAliveData):void;
		function get messageId():String;
		function set messageId(v:String):void;
		function get groupsToken():String;
		function set groupsToken(v:String):void;
		function get items():Dictionary;

		function get connectionId():String;

		function get connectionToken():String;
		
		function get url():URI;
		
		function get queryString():String;
		
		function get state():ConnectionState;
		
		function get transport():IClientTransport;
		
		function get lastMessageAt():Number;
		
		function get lastActiveAt():Number;
		
		
		//IWebProxy Proxy { get; set; }
		
		function changeState(oldState:ConnectionState, newState:ConnectionState):Boolean;
		
		function get headers():Dictionary;
		
		function get credentials():ICredentials;
		function set credentials(v:ICredentials):void;
		//function get cookieContainer():CookieContainer
		function get jsonSerializer():JSONWrapper;
		function get monitor():HeartbeatMonitor;
		function get version():String;
			
		function init(url:String, qs:String = null, logging:Boolean = false):void;
		
		function start():ITask;
		function startWithTransport(transport:IClientTransport):ITask;
		function stop():void;
		function disconnect():void;
		function send(data:Object):ITask;
		
		function onMessageReceived(message:Object):void;
		function onSending():String;
		function onClosed():void;
		function onReceived(data:Object):void;
		function onError(ex:Object):void;
		function onReconnecting():void;
		function onReconnected():void;
		function onConnectionSlow():void;
		function prepareRequest(request:IRequest):void;
		function markLastMessage():void;
		function markActive():Boolean;
		function log(msg:String, ...args):void;
		
		
	}
}