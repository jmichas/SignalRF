package com.michas.signalRF.events
{
	public class SignalRReceivedEvent extends SignalREvent
	{
		public var message:Object;
		
		public function SignalRReceivedEvent(type:String, message:Object, callback:Function=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.message = message;
			super(type, callback, bubbles, cancelable);
		}
	}
}