package com.michas.async {
	
	/**
	 * Represents a result that will be available in the future.
	 * @author jmichas
	 * 
	 */	
	public interface ITask {
		/**
		 * Determines if the task has completed successfully.
		 * @return 
		 * 
		 */		
		function isCompleted() : Boolean;
		
		/**
		 * Determines if the task has 'completed' due to an error.
		 * @return 
		 * 
		 */		
		function isFaulted() : Boolean;
		
		/**
		 * Determines if the task has faulted due to cancellation.
		 * @return 
		 * 
		 */		
		function isCancelled() : Boolean;

		/**
		 * Determines if the task has not yet completed or faulted.
		 * @return 
		 * 
		 */		
		function isRunning() : Boolean;
		
		/**
		 * Returns the task's result. Fails if the task has not completed successfully.
		 * @return 
		 * 
		 */		
		function result() : *;
		
		/**
		 * Returns the task's fault. Fails if the task has not faulted.
		 * @return 
		 * 
		 */		
		function fault() : *;
		
		/**
		 * Runs a callback after the given task completes or faults, returning the callback's eventual result as a task.
		 * If the given task has already completed then the callback may be run synchronously.
		 * @param callback The callback must take 0 arguments.
		 * @return 
		 * 
		 */		
		function await(callback : Function) : ITask;
		
		/**
		 * Runs a callback using the result of the given task, returning the callback's eventual result as a task.
		 * If the given task faults then the fault is propagated into the resulting task, and the callback is not run.
		 * If the given task has already completed then the callback may be run synchronously.
		 * @param callback The callback must take 0 arguments or 1 argument for the task's result.
		 * @return 
		 * 
		 */		
		function continueWith(callback : Function) : ITask;
		
		/**
		 * Returns a Task<T> with result equivalent to the eventual Task<T> resulting from this Task<Task<T>>.
		 * Intuitively, it transforms this Task<Task<T>> into a Task<T> in the reasonable way.
		 * If either this Task<Task<T>> or its resulting Task<T> fault, the returned Task<T> will also fault.
		 * @return 
		 * 
		 */		
		function unwrap() : ITask;
		
		/**
		 * Runs a callback using the unwrapped result of the given task, returning the callback's eventual result as a task.
		 * Equivalent to ContinueWith(callback).Unwrap()
		 * @param callback
		 * @return 
		 * 
		 */		
		function bind(callback : Function) : ITask;
		 
		/**
		 * Runs a callback based on the failure of the given task, returning the callback's eventual result as a task.
		 * If the given task does not fault, the resulting task will contain a null result.
		 * If the given task has already completed then the callback may be run synchronously.
		 * @param callback The callback must take 0 arguments or 1 argument for the task's fault.
		 * @return 
		 * 
		 */		
		function catchWith(callback : Function) : ITask;
		
		//function wait(timeout:Number):
	}
}
