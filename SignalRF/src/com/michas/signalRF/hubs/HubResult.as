package com.michas.signalRF.hubs
{
	import flash.utils.Dictionary;

	public class HubResult
	{
		/// <summary>
		/// The callback identifier
		/// </summary>
		//[JsonProperty("I")]
		public var id:String;

		/// <summary>
		/// The return value of the hub
		/// </summary>
		//[JsonProperty("R")]
		public var result:*;

		/// <summary>
		/// Indicates whether the Error is a <see cref="HubException"/>.
		/// </summary>
		//[JsonProperty("H")]
		public var isHubException:Boolean;

		/// <summary>
		/// The error message returned from the hub invocation.
		/// </summary>
		//[JsonProperty("E")]
		public var error:String;

		/// <summary>
		/// Extra error data
		/// </summary>
		//[JsonProperty("D")]
		public var errorData:Object;

		/// <summary>
		/// The caller state from this hub.
		/// </summary>
		//[JsonProperty("S")]
		public var state:Dictionary;

		public function HubResult(message:Object = null)
		{
			isHubException = false;
			state = new Dictionary();
			
			if(message!=null){
				id = message.I;
				result = message.R;
				isHubException = message.H!=null ? Boolean(message.H) : false;
				error = message.E;
				errorData = message.D;
				state = message.S;
			}
		}
		
		/**
		 * Takes a JSON object received from the server and expands the properties for readability. 
		 * @param o JSON Object received from server
		 * @return The converted HubResult object
		 * 
		 */		
		private function maximize(o:Object):HubResult{
			var hubResult:HubResult = new HubResult();
			hubResult.id = o.I;
			hubResult.result = o.R;
			hubResult.isHubException = o.H!=null ? Boolean(o.H) : false;
			hubResult.error = o.E;
			hubResult.errorData = o.D;
			hubResult.state = o.S;
			
			return hubResult;
		}
	}
}