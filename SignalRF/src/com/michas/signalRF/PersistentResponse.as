package com.michas.signalRF
{
	public class PersistentResponse
	{
		public var messageId:String;
		public var messages:Array;
		public var initialized:Boolean;
		public var disconnect:Boolean;
		public var shouldReconnect:Boolean;
		public var longPollDelay:String;
		public var groupsToken:String;
		
		public function PersistentResponse()
		{
		}
	}
}