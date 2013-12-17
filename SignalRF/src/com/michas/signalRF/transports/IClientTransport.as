package com.michas.signalRF.transports
{
	import com.michas.async.CancelTokenSource;
	import com.michas.async.ITask;
	import com.michas.signalRF.IConnection;

	public interface IClientTransport
	{
		function get name():String;
		function get supportsKeepAlive():Boolean;
		
		function negotiate(connection:IConnection, connectionData:String):ITask;
		function start(connection:IConnection, connectionData:String, disconnectToken:CancelTokenSource):ITask;
		function stop(connection:IConnection):ITask
		function send(connection:IConnection, data:String, connectionData:String):ITask;
		function abort(connection:IConnection, timeout:Number, connectionData:String):void;
		
		function lostConnection(connection:IConnection):void;
		
		/*
		string Name { get; }
		bool SupportsKeepAlive { get; }
		
		Task<NegotiationResponse> Negotiate(IConnection connection, string connectionData);
		Task Start(IConnection connection, string connectionData, CancellationToken disconnectToken);
		Task Send(IConnection connection, string data, string connectionData);
		void Abort(IConnection connection, TimeSpan timeout, string connectionData);
		
		void LostConnection(IConnection connection);
		*/
	}
}