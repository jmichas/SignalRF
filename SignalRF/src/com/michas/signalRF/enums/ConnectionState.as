package com.michas.signalRF.enums
{
	public class ConnectionState extends AbstractEnumerable
	{
		/*
		signalR.connectionState = {
		connecting: 0,
		connected: 1,
		reconnecting: 2,
		disconnected: 4
		}; 
		*/
		
		public static const CONNECTING:ConnectionState = new ConnectionState();//"connecting";
		public static const CONNECTED:ConnectionState = new ConnectionState();//"connected";
		public static const RECONNECTING:ConnectionState = new ConnectionState();//"reconnecting";
		public static const DISCONNECTED:ConnectionState = new ConnectionState();//"disconnected";
		
		{
			initEnum(ConnectionState);
		}
		
		public function ConnectionState()
		{
		}
	}
}