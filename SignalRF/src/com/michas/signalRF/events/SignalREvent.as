package com.michas.signalRF.events
{
	import flash.events.Event;
	
	public class SignalREvent extends Event
	{
		/*
		onStart: "onStart",
		onStarting: "onStarting",
		onReceived: "onReceived",
		onError: "onError",
		onConnectionSlow: "onConnectionSlow",
		onReconnecting: "onReconnecting",
		onReconnect: "onReconnect",
		onStateChanged: "onStateChanged",
		onDisconnect: "onDisconnect"
		*/
		
		public static const START:String = "signalR_onStart";
		public static const STARTING:String = "signalR_onStarting";
		public static const RECEIVED:String = "signalR_onReceived";
		public static const ERROR:String = "signalR_onError";
		public static const CONNECTION_SLOW:String = "signalR_onConnectionSlow";
		public static const RECONNECTING:String = "signalR_onReconnecting";
		//public static const RECONNECT:String = "signalR_onReconnect";
		public static const RECONNECTED:String = "signalR_onReconnected";
		public static const STATE_CHANGED:String = "signalR_onStateChanged";
		public static const DISCONNECTED:String = "signalR_onDisconnected";
		public static const CLOSED:String = "signalR_onClosed";
		
		public var callback:Function;
		public static const CONNECTED:String = "signalR_connected";
		
		public function SignalREvent(type:String, callback:Function=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.callback = callback;
			super(type, bubbles, cancelable);
		}
	}
}