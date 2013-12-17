package com.michas.async {
	import flash.errors.IllegalOperationError;
	
	/**
	 * Utility methods for working with tasks
	 * @author jmichas
	 * 
	 */	
	public class TaskEx {

		/**
		 * Returns a completed task whose result is the given value.
		 * @param value
		 * @param deferred The 'deferred' argument determine if the task is returned completed or defers completion.
		 * @return 
		 * 
		 */		
		public static function wrap(value : Object, deferred : Boolean = false) : ITask {
			var r:TaskSource = new TaskSource();
			if (deferred) {
				Util.defer(function():void { r.setResult(value); });
			} else {
				r.setResult(value)
			}
			return r;
		}
	

		/**
		 * Returns a faulted task whose error is the given value.
		 * @param error
		 * @param deferred The 'deferred' argument determine if the task is returned faulted or defers faulting.
		 * @return 
		 * 
		 */		
		public static function wrapFault(error : Object, deferred : Boolean = true) : ITask {
			var r:TaskSource = new TaskSource();
			if (deferred) {
				Util.defer(function():void { r.setFault(error); });
			} else {
				r.setFault(error)
			}
			return r;
		}
		
		/**
		 * Starts tasks based on items from a sequence, returning a task containing the array of results of the started tasks.
		 * @param inputs
		 * @param taskStarter
		 * @return 
		 * 
		 */		
		public static function startMany(inputs:*, taskStarter:Function):ITask {
			var tasks:Array = new Array();
			for each (var e:Object in inputs)
				tasks.push(taskStarter(e));
			return awaitAll(tasks);
		}
		
		
		/**
		 * Awaits all the tasks in a sequence and passes them each as individualarguments to the given callback function.
		 * The resulting task is the eventual result of the callback, or the fault(s) from awaiting the sequence of tasks.
		 * @param tasks
		 * @param callback
		 * @return 
		 * 
		 */		
		public static function continueWithMany(tasks:*, callback:Function):ITask {
			return awaitAll(tasks).continueWith(function(v:Array):* {
				return callback.apply(null, v);
			});
		}

		
		/**
		 * Awaits all the tasks in a sequence and passes them each as individualarguments to the given callback function.
		 * The resulting task is the unwrapped eventual result of the callback, or the fault(s) from awaiting the sequence of tasks.
		 * @param tasks
		 * @param callback
		 * @return 
		 * 
		 */		
		public static function bindMany(tasks:*, callback:Function):ITask {
			return awaitAll(tasks).bind(function(v:Array):ITask {
				return callback.apply(null, v);
			});
		}

		/**
		 * Returns a Task<T> with the same result except it faults if the given task doesn't complete within the timeout.
		 * @param task
		 * @param timeoutMilliseconds
		 * @return 
		 * 
		 */		
		public static function withTimeout(task:ITask, timeoutMilliseconds : Number):ITask {
			var r:TaskSource = new TaskSource();
			task.await(function():void {
				if (r.isRunning()) r.setFromTask(task, true);
			} );
			TaskInterop.delay(timeoutMilliseconds).await(function():void { 
				if (r.isRunning()) r.setFault(new IllegalOperationError("Timeout"));
			} );
			return r;
		}
		

		/**
		 * Returns a Task<Array<T>> that completes with the results of the tasks in the given sequence of Task<T> once they are ready.
		 * If one or many of the tasks fault, the resulting task faults with an aggregate error.
		 * @param tasks
		 * @return 
		 * 
		 */		
		public static function awaitAll(tasks:*):ITask {
			if (tasks == null) throw new ArgumentError("tasks == null");
			var r:TaskSource = new TaskSource();
			if (tasks.length == 0) r.setResult(new Array(0));
			var L:Array = new Array();
			var n:int = 0;
			var E:Array = new Array();
			for (var i:int = 0; i < tasks.length; i++) {
				var g:Function = function():void {
					var i_:int = i;
					var t:ITask = tasks[i_];
					L.push(null);
					t.await(function():void {
						n += 1;
						if (t.isFaulted()) E.push(t.fault());
						if (t.isCompleted()) L[i_] = t.result();
						if (n == tasks.length) {
							if (E.length == 0) {
								r.setResult(L);
							} else {
								r.setFault(new AggregateError(E).collapse());
							}
						}
					});
				};
				g();
			}
			return r;
		}
		
		
		/**
		 * Returns a Task<T> that completes with the result or fault of one of the tasks in the given Array<Task<T>>.
		 * Does not prioritize results over faults.
		 * Throws an error when given 0 tasks.
		 * @param tasks
		 * @return 
		 * 
		 */		
		public static function awaitAny(tasks:*):ITask {
			if (tasks == null) throw new ArgumentError("tasks == null");
			if (tasks.length == 0) throw new ArgumentError("tasks.length == 0");
			var r:TaskSource = new TaskSource();
			for each (var t:ITask in tasks) {
				if (!r.isRunning()) break;
				var f:Function = function():void {
					var t_:ITask = t;
					t.await(function():void {
						if (r.isRunning()) r.setFromTask(t_, true);
					});
				};
				f();
			}
			return r;
		}

		/**
		 * Returns a list of tasks with the same results, but re-ordered so that idle tasks do not delay iteration.
		 * Completed tasks will be ordered before incomplete tasks.
		 * The ordering amongst already completed tasks is not defined.
		 * @param tasks
		 * @return 
		 * 
		 */		
		public static function orderedByCompletion(tasks:Array) : Vector.<ITask> {
			if (tasks == null) throw new ArgumentError("tasks == null");
			var r:Array = new Array();
			var i:int = 0;
			for each (var t:ITask in tasks) {
				r.push(new TaskSource());
				var f:Function = function(t_:ITask):void {
					t_.await(function():void {
						r[i].SetFromTask(t_, true);
						i += 1;
					});
				};
				f(t);
			}
			return Vector.<ITask>(r);
		}
		 
		/**
		 * Repeatedly evaluates a condition function until its eventual result is not true.
		 * The resulting task completes when the condition function's eventual result is false, or faults if the condition function's result faults.
		 * @param loopBodyCondition The loopBodyCondition function should return a Task<Boolean>
		 * @return 
		 * 
		 */		
		public static function doWhile(loopBodyCondition : Function) : ITask {
			var f:Function = function():ITask {
				var t:ITask = loopBodyCondition();
				return t.bind(function(cont:Boolean):ITask {
					if (!cont) return TaskEx.wrap(false);
					return f();
				});
			}
			return f();
		}
	}
}
