package com.michas.signalRF.interfaces
{
	public interface ISignalRObject
	{
		/**
		 * This should parse the result object and assign its properties to this. 
		 * 
		 * <p>
		 * Typically should be something like:<br/>
		 * <code>
		 * for (var prop:String in result){<br/>
				try{<br/>
					this[prop] = result[prop];<br/>
				}catch(e:Error){<br/>
					trace(e.message);<br/>
				}<br/>
			}<br/>
		 * </code>
		 * 
		 * But, you may need to do more processing for nested objects or custom logic etc.
		 * </p>
		 * <p>
		 * This method is used by the framework when invoke$T is called to cast the result to the desired return type.
		 * </p>
		 * @param result The JSON object returned by the server.
		 * 
		 * 
		 * 
		 */		
		function parse(result:Object):void;
	}
}