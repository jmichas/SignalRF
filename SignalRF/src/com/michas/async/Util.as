package com.michas.async {
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	internal class Util {
		public static function addOneTimeEventHandlerTo(obj : Object, event : String, callback : Function) : void {
			var f : Function = function(arg : Object) : void {
				obj.removeEventListener(event, f);
				callback(arg);
			};
			obj.addEventListener(event, f);
		}
		/// Runs the given function after the current execution stack has completed.
		public static function defer(callback : Function):void {
			delay(0, callback);
		}
		/// Runs the given function after a given delay.
		public static function delay(delayMilliseconds : Number, callback : Function):void {
			var t:Timer = new Timer(delayMilliseconds, 1);
			t.start();
			Util.addOneTimeEventHandlerTo(t, TimerEvent.TIMER_COMPLETE, function(e:TimerEvent):void { callback(); });
		}
	}
}
