package com.michas.async {
	/// 
	/// 
	/**
	 * A cancel token that will never be cancelled.
	 * Callbacks passed to onCancelled will never be run.
	 * @author jmichas
	 * 
	 */	
	public class NeverCancelToken implements ICancelToken {
		public function NeverCancelToken() { }
		public function isCancelled() : Boolean { return false; }
		public function onCancelled(callback : Function):void { }
		public function toString():String { return "Never Cancelled"; }
	}
}
