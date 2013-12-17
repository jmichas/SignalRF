package com.michas.signalRF.events
{
	public class SignalRErrorEvent extends SignalREvent
	{
		public var message:Object;
		
		public function SignalRErrorEvent(type:String, message:Object, callback:Function=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.message = message;
			super(type, callback, bubbles, cancelable);
		}
	}
}