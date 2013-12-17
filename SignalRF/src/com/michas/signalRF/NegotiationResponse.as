package com.michas.signalRF
{
	
	public class NegotiationResponse
	{
		/*
		{"Url":"/signalr",
		"ConnectionToken":"rARqzVf0ktUGqKI482sUIR6OUtR/3My60p+wpxa5GibdocZaNK34Nn2XY3F0L+xAXm8HqQm+PyVQCK+5bcsFFODDSax6zsn9XytjYGzkeaxldLYR21vF44lHKcfCvIWO",
		"ConnectionId":"308e89eb-3c1a-488f-9e47-869c89f9e1bd",
		"KeepAliveTimeout":20.0,
		"DisconnectTimeout":30.0,
		"TryWebSockets":true,
		"ProtocolVersion":"1.3",
		"TransportConnectTimeout":5.0}
		*/
		
		public var url:String;
		public var connectionToken:String;
		public var connectionId:String;
		public var keepAliveTimeout:Number;
		public var disconnectTimeout:Number;
		public var tryWebSockets:Boolean;
		public var protocolVersion:String;
		public var transportConnectTimeout:Number;
		
		
		/**
		 * Create new NegotiationResponse.
		 * Encompasses all the data received from the server on first connect during the negotiation phase. 
		 * @param jsonObj [optional] a JSON string or object parsed by the JSON.parse() method. If a json string is passed it will be converted to an object automatically.
		 * 
		 * <p>
		 * Properties<br/>
		 * <code>
		 * public var url:String;<br/>
		 * public var connectionToken:String;<br/>
		 * public var connectionId:String;<br/>
		 * public var keepAliveTimeout:Number;<br/>
		 * public var disconnectTimeout:Number;<br/>
		 * public var tryWebSockets:Boolean;<br/>
		 * public var protocolVersion:String;<br/>
		 * public var transportConnectTimeout:Number;<br/>
		 * </code>
		 * </p>
		 */	
		public function NegotiationResponse(jsonObj:Object = null)
		{
			if(jsonObj!=null){
				if(jsonObj is String){
					jsonObj = JSON.parse(String(jsonObj));
				}
				for( var prop:String in jsonObj ) {
					var camelProp:String = prop.substr(0,1).toLowerCase() + prop.substr(1);
					this[camelProp] = !isNaN(jsonObj[prop]) ? Number(jsonObj[prop]) : jsonObj[prop];
				}
			}
		}
	}
}