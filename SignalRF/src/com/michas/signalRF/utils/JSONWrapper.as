package com.michas.signalRF.utils
{
	public class JSONWrapper
	{
		public function stringify(value:Object, replacer:* = null, space:* = null):String{
			return JSON.stringify(value,replacer,space);
		}
		
		public function parse(text:String, reviver:Function = null):Object{
			return JSON.parse(text,reviver);
		}
		
	}
}