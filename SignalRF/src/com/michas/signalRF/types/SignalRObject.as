package com.michas.signalRF.types
{
	import com.adobe.utils.DateUtil;
	import com.michas.signalRF.interfaces.ISignalRObject;
	
	import flash.utils.describeType;
	
	/**
	 * All objects passed by your code should extend this class.
	 * <p>
	 * This base class includes a parse() method that is called by the framework when data is returned from the server so that invoke$T can return the data in the type specified by $T. 
	 * </p>
	 * <p>
	 * The parse method should be overridden if your object contains nested complex types ie a Game that contains Player objects. You will need to parse the nested objects manually or they will be returned as simple Object types.
	 * </p>
	 * <p>
	 * The default parse code is:<br/>
	 * <code>
	 * <pre>
if(typeof(result) == "string"){
	result = JSON.parse(String(result));
}

var _typeDescription:XML = describeType(this);

for (var prop:String in result){
	try{
		if(_typeDescription.variable.(&#64;name == prop).&#64;type == "Date"){
			this[prop] = DateUtil.parseW3CDTF(result[prop] + "-00:00");
		}else{
			this[prop] = result[prop];
		}
	}catch(e:Error){
		throw e;
	}
}
		</pre>
		</code>
	 * </p>
	 * @author jmichas
	 * 
	 */	
	public class SignalRObject implements ISignalRObject
	{
		public function SignalRObject()
		{
		}
		
		public function parse(result:Object):void{
			if(typeof(result) == "string"){
				//we know this should have been decoded JSON as an object
				//if not we need to decode it here, put in to support Backbone SignalR on the server.
				result = JSON.parse(String(result));
			}
			
			var _typeDescription:XML = describeType(this);
			
			for (var prop:String in result){
				var _type:String = _typeDescription.variable.(@name == prop).@type;
				if(_type==""){
					//if the object is bindable it uses accessor
					_type = _typeDescription.accessor.(@name == prop).@type
				}
				try{
					if(_type == "Date"){
						this[prop] = DateUtil.parseW3CDTF(result[prop] + "-00:00");
					}else{
						this[prop] = result[prop];
					}
				}catch(e:Error){
					throw e;
				}
			}
		}
	}
}