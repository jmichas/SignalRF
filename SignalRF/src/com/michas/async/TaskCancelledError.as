package com.michas.async {
	
	/**
	 * An error indicating a task has no result because it was cancelled.
	 * @author jmichas
	 * 
	 */	
	public class TaskCancelledError extends Error {
		public function TaskCancelledError() {
			super("Task Cancelled");
		}
	}
}
