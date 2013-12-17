package com.michas.signalRF
{
	public class KeepAliveData
	{
		private const _keepAliveWarnAt:Number = 2.0 / 3.0;
		
		public var timeout:Number;
		public var timeoutWarning:Number;
		public var checkInterval:Number;
		
		//public var lastKeepAlive:Number;
		//public var userNotified:Boolean;
		//public var monitoring:Boolean;
		//public var activated:Boolean;
		//public var reconnectKeepAliveUpdate:Function;
		
		/**
		 * 
		 * @param timeout Timeout in seconds. (will be converted to milliseconds)
		 * 
		 */		
		public function KeepAliveData(timeout:Number)
		{
			this.timeout = timeout * 1000;
			timeoutWarning = this.timeout * _keepAliveWarnAt;
			checkInterval = (this.timeout - timeoutWarning) / 3;
		}
		
		/**
		 * All values should be in milliseconds
		 * @param timeout 
		 * @param timeoutWarning
		 * @param checkInterval
		 * @return 
		 * 
		 */		
		public function setValues(timeout:Number, timeoutWarning:Number, checkInterval:Number):void{
			this.timeout = timeout;
			this.timeoutWarning = timeoutWarning;
			this.checkInterval = checkInterval;
		}
	}
}