package com.michas.async {
	
	/**
	 * A cancel token with manually controlled cancellation.
	 * @author jmichas
	 * 
	 */	
	public class CancelTokenSource implements ICancelToken {
		private var _cancelled:Boolean = false;
		private var _callbacks:Vector.<Function> = new Vector.<Function>();
		
		public function CancelTokenSource() {}
		public function isCancelled() : Boolean {
			return _cancelled;
		}
		
		/**
		 * Cancels the token.
		 * 
		 */		
		public function cancel():void {
			if (_cancelled) return;
			_cancelled = true;
			for each (var c:Function in _callbacks) {
				Util.defer(c);
			}
			_callbacks = null;
		}
		public function onCancelled(callback : Function):void {
			if (callback == null) throw new ArgumentError("callback == null");
			if (callback.length != 0) throw new ArgumentError("callback.length != 0");
			if (_cancelled) {
				Util.defer(callback);
			} else {
				_callbacks.push(callback);
			}
		}

		public function toString():String {
			return _cancelled ? "Cancelled" : "Not Cancelled";
		}
	}
}
