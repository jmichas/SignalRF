package com.michas.signalRF.events
{
	import com.michas.signalRF.enums.ConnectionState;

	public class SignalRStateChangedEvent extends SignalREvent
	{
		public var oldState:ConnectionState;
		public var newState:ConnectionState;
		
		public function SignalRStateChangedEvent(type:String, oldState:ConnectionState, newState:ConnectionState, callback:Function = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.oldState = oldState;
			this.newState = newState;
			this.callback = callback;
			
			super(type, callback, bubbles, cancelable);
		}
	}
}