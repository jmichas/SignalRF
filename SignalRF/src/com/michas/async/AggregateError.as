package com.michas.async {
	
	/**
	 * An error that is actually multiple errors
	 * @author jmichas
	 * 
	 */	
	public class AggregateError extends Error {
		public var causes:Array;
		public function AggregateError(causes:Array) {
			super("AggregateError: " + summarize(causes));
			this.causes = causes;
		}
		public function collapse() : Object {
			if (causes.length != 1) return this;
			if (causes[0] is AggregateError) return (causes[0] as AggregateError).collapse();
			return causes[0];
		}
		private static function summarize(causes:Array, sep:String = ", ") : String {
			var r:String = "";
			for each (var e:* in causes) {
				if (r.length > 0) r += sep;
				r += e + "";
			}
			return r;
		}
		public function toString(): String {
			return "AggregateError:\r\n" + summarize(causes, "\r\n");
		}
		public function getStackTraces() : String {
			var r:String = super.getStackTrace() + "\r\n";
			for each (var e:* in causes) {
				r += "\r\n---\r\n";
				r += e is Error ? (e as Error).getStackTrace() : "(none)";
			}
			return r;			
		}
	}
}