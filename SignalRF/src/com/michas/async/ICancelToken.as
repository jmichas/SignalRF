package com.michas.async {
	import flash.errors.IllegalOperationError;
	public interface ICancelToken {
		
		
		/**
		 * Provides a callback to run when the token has been cancelled.
		 * If the token is already canceled then the callback may be run defered or run synchronously
		 * @param callback
		 * 
		 */		
		function onCancelled(callback : Function) : void;
		
		/**
		 * Determines if the token has already been cancelled
		 * @return 
		 * 
		 */		
		function isCancelled() : Boolean;
	}
}
