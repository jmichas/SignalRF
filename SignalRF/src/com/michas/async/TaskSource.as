package com.michas.async {
	import flash.errors.IllegalOperationError;

	/**
	 * A Task with manually controlled completion.
	 * For example, a method can create a TaskSource, returning it to the caller, and manually set its result when possible.
	 * @author jmichas
	 * 
	 */	
	public class TaskSource implements ITask {
		/// When set to true exceptions will bubble out of the call stack instead of being propagated into the task source.
		/// Makes it easier to debug exceptions by stopping the debugger at the right time.
		private static const DEBUG_EVAL_WITHOUT_TRYCATCH:Boolean = true;
		
		// When set to true, task sources store a stack trace when they are constructed, to help identify where they came from.
		private static const DEBUGGING_STORE_CREATION_STACK_TRACE:Boolean = true;
		private var DEBUG_CREATION_STACK_TRACE : String;

		/// A count of TaskSource instances that have been created but not yet set.
		/// A TaskSource instance should not be created if it won't be eventually set.
		/// This value can be useful for determining if a bug is due to a task source not being set vs being set incorrectly.
		private static var DEBUG_UNSET_COUNT : int = 0;
		
		/// When set to true, task sources will output faults that appear to have not been handled
		private static const DEBUG_TRACE_PROBABLE_UNHANDLED_FAULTS:Boolean = true;

		private var _result:*;
		private var _state:int = 0;
		private var _callbacks:Vector.<Function> = new Vector.<Function>();
		private var _hasBeenAwaited:Boolean = false;
		
		/**
		 * Constructs a new task source.
		 * 
		 */		
		public function TaskSource() {
			DEBUG_UNSET_COUNT += 1;
			if (DEBUGGING_STORE_CREATION_STACK_TRACE)
				this.DEBUG_CREATION_STACK_TRACE = new Error().getStackTrace();
		}
		public function isCompleted() : Boolean {
			return _state == 1;
		}
		public function isFaulted() : Boolean {
			return _state == -1;
		}
		public function isCancelled() : Boolean {
			return isFaulted() && _result is TaskCancelledError;
		}
		public function isRunning() : Boolean {
			return _state == 0;
		}
		
		public function result() : * {
			if (this.isFaulted())
				throw new IllegalOperationError("Task's result can't be accessed because the task faulted. The fault: " + _result);
			if (!this.isCompleted())
				throw new IllegalOperationError("Task's result can't be accessed because the task is still running.");
			return _result;
		}
		public function fault() : * {
			if (this.isCompleted())
				throw new IllegalOperationError("Task's fault can't be accessed because the task completed successfully. The result: " + _result);
			if (!this.isFaulted())
				throw new IllegalOperationError("Task's fault can't be accessed because the task is still running.");
			return _result;
		}
		
		public function trySetResult(result : *):Boolean {
			if (!this.isRunning()) return false;
			_state = 1;
			_result = result;
			runAndClearCallbacks();
			return true;
		}
		public function trySetFault(fault : *):Boolean {
			if (!this.isRunning()) return false;
			_state = -1;
			_result = fault;
			if (DEBUG_TRACE_PROBABLE_UNHANDLED_FAULTS && !_hasBeenAwaited) {
				Util.defer(function():void { 
					if (!_hasBeenAwaited) {
						trace("Task fault may not have been handled: " + fault);
					}
				});
			}
			runAndClearCallbacks();
			return true;
		}
		public function trySetCancelled():Boolean {
			return trySetFault(new TaskCancelledError());
		}
		private function runAndClearCallbacks():void {
			DEBUG_UNSET_COUNT -= 1;
			
			for each (var c:Function in _callbacks) {
				c();
			}
			_callbacks = null;
		}
		
		public function setCancelled():void {
			if (!trySetCancelled())
				throw new IllegalOperationError("Task is already set.");
		}
		public function setResult(result : Object):void {
			if (!trySetResult(result)) 
				throw new IllegalOperationError("Task is already set.");
		}
		public function setFault(fault : Object):void {
			if (!trySetFault(fault)) 
				throw new IllegalOperationError("Task is already set.");
		}
		
		/// Evaluates a function, propagating the result or exception into the TaskSource
		/**
		 * Evaluates a function, propagating the result or exception into the TaskSource 
		 * @param f
		 * 
		 */		
		private function setByEval(f:Function):void {
			if (DEBUG_EVAL_WITHOUT_TRYCATCH) {
				setResult(f());
				return;
			}
			
			try {
				setResult(f());
			} catch (error:*) {
				setFault(error);
			}
		}
		/// Copies a task's result or fault into this task source.
		/**
		 * Copies a task's result or fault into this task source. 
		 * @param task
		 * @param assertTaskCompleted
		 * 
		 */		
		public function setFromTask(task:ITask, assertTaskCompleted:Boolean = false):void {
			if (task.isCompleted()) {
				setResult(task.result());
			} else if (task.isFaulted()) {
				setFault(task.fault());
			} else if (assertTaskCompleted) {
				throw new IllegalOperationError("Task expected to be completed or faulted.");
			} else {
				task.await(function():void { setFromTask(task, true); } );
			}
		}

		public function await(callback : Function):ITask {
			if (callback == null) throw new ArgumentError("callback == null");
			if (callback.length != 0) throw new ArgumentError("callback.length != 0");
			_hasBeenAwaited = true;
			var r:TaskSource = new TaskSource();
			var fullCallback:Function = function():void { r.setByEval(callback); }
			if (isRunning()) {
				_callbacks.push(fullCallback);
			} else {
				fullCallback();
			}
			return r;
		}
		public function continueWith(callback : Function):ITask {
			if (callback == null) throw new ArgumentError("callback == null");
			if (callback.length > 1) throw new ArgumentError("callback.length > 1");
				
			var r:TaskSource = new TaskSource();
			await(function():void {
				if (isFaulted()) {
					r.setFault(fault());
				} else {
					r.setByEval(function():Object { 
						return callback.length == 0
							   ? callback()
							   : callback(result());
					});
				}
			});
			return r;
		}
		public function catchWith(callback : Function):ITask {
			if (callback == null) throw new ArgumentError("callback == null");
			if (callback.length > 1) throw new ArgumentError("callback.length > 1");
			
			return await(function():Object { 
				if (!isFaulted()) return null;
				return callback.length == 0
					   ? callback()
					   : callback(fault());
			} );
		}
		
		public function unwrap():ITask {
			var r:TaskSource = new TaskSource();
			await(function():void { 
				if (isFaulted()) {
					r.setFault(fault());
				} else {
					var t:ITask = result() as ITask;
					if (t == null) throw new ArgumentError("Attempted to unwrap a task that did not wrap a task.");
					r.setFromTask(t);
				}
			});
			return r;
		}
		public function bind(callback : Function):ITask {
			return continueWith(callback).unwrap();
		}

		public function toString():String {
			if (isFaulted()) return "Faulted Task: " + _result;
			if (isCompleted()) return "Completed Task: " + _result;
			return "Incomplete Task";
		}
	}
}
