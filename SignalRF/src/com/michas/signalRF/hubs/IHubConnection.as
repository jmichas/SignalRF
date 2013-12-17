package com.michas.signalRF.hubs
{
	import com.michas.signalRF.IConnection;
	import com.michas.signalRF.IHubProxy;

	public interface IHubConnection extends IConnection
	{
		function createHubProxy(hubName:String):IHubProxy;
		function registerCallback(callback:Function):String;
		function removeCallback(callbackId:String):void;
	}
}