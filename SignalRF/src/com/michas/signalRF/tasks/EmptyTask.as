package com.michas.signalRF.tasks
{
	import com.michas.async.ITask;
	
	public class EmptyTask implements ITask
	{
		public function EmptyTask()
		{
		}
		
		public function isCompleted():Boolean
		{
			return false;
		}
		
		public function isFaulted():Boolean
		{
			return false;
		}
		
		public function isCancelled():Boolean
		{
			return false;
		}
		
		public function isRunning():Boolean
		{
			return false;
		}
		
		public function result():*
		{
			return null;
		}
		
		public function fault():*
		{
			return null;
		}
		
		public function await(callback:Function):ITask
		{
			return null;
		}
		
		public function continueWith(callback:Function):ITask
		{
			return null;
		}
		
		public function unwrap():ITask
		{
			return null;
		}
		
		public function bind(callback:Function):ITask
		{
			return null;
		}
		
		public function catchWith(callback:Function):ITask
		{
			return null;
		}
	}
}