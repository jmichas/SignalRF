package com.michas.signalRF.hubs
{
	public class HubException extends Error
	{
		private var _errorData:Object;
		
		
		public function HubException(message:String = "", errorData:Object = null)
		{
			_errorData = errorData;
			super(message, 1901);
		}
		
		public function get errorData():Object{
			return _errorData;
		}
	}
}