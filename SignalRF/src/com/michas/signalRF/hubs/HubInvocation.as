package com.michas.signalRF.hubs
{
	import flash.utils.Dictionary;
	
	public class HubInvocation
	{
		public function HubInvocation(message:Object = null)
		{
			state = new Dictionary();
			if(message!=null){
				callbackId = message.I;
				hub = message.H;
				method = message.M;
				args = message.A;
				state = message.S;
			}
		}
		
		/**
		 * Returns the minified version of the object for serialization and transport. 
		 * @return 
		 * 
		 */		
		public function minify():Object{
			var min:Object = new Object();
			min.I = callbackId;
			min.H = hub;
			min.M = method;
			min.A = args;
			min.S = state;//dictToJSON(state);
			
			return min;
		}
		
		//[JsonProperty("I")]
		public var callbackId:String;
		
		//[JsonProperty("H")]
		public var hub:String;
		
		//[JsonProperty("M")]
		public var method:String;

		//[JsonProperty("A")]
		public var args:Array;
		
		//[JsonProperty("S", NullValueHandling = NullValueHandling.Ignore)]
		public var state:Dictionary;
	}
}