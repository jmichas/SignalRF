package com.michas.signalRF.hubs
{
	import avmplus.getQualifiedClassName;

	public class Subscription
	{
		public function Subscription()
		{
		}
		public var $T:Class;
		public var received:Function;
		
		/**
		 * This will unwrap the args received from the server and convert them to an object of $T or an Array of $T if there are more than one. 
		 * @param args Array of args returned by signalR server.
		 * @return $T or Array of $T
		 * 
		 */		
		public function onReceived(args:Array):void{
			if(args.length == 1){
				try{
					
					if(getQualifiedClassName($T)!="Object"){
						var obj:* = new $T()
						obj.parse(args[0]);
						received(obj);
					}else{
						received(args[0]);
					}
				}catch(err:Error){
					throw new Error(err.message + "\nError SignalR: $T must be a class that extends SignalRObject.");
				}
			}else{
				// we have a collection
				var array:Array = new Array();
				for(var x:int = 0 ; x < args.length; x++){
					try{
						
						if(getQualifiedClassName($T)!="Object"){
							var obj2:* = new $T()
							obj2.parse(args[x]);
							array.push(obj2);
						}else{
							array.push(args[x]);
						}
					}catch(err:Error){
						throw new Error(err.message + "\nError SignalR: $T must be a class that extends SignalRObject.");
					}
				}
				received(array);
			}
		}
	}
}