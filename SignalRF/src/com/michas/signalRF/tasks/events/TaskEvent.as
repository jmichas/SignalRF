/* ***** BEGIN MIT LICENSE BLOCK *****
* 
* Copyright (c) 2009 DevelopmentArc LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
* 
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*
*
* ***** END MIT LICENSE BLOCK ***** */
package com.michas.signalRF.tasks.events
{
	import flash.events.Event;
	
	/**
	 * The TaskEvent is dispatched by Tasks and TaskGroups as they are processed
	 * by the TaskController and/or are changing state as they process their current
	 * functionality or childeren tasks.
	 * 
	 * @see com.developmentarc.core.controllers.TaskController
	 * @see com.developmentarc.core.datastructures.tasks.TaskGroup
	 * 
	 * @author James Polanco
	 * 
	 */
	public class TaskEvent extends Event
	{
		/**
		 * Defines when a Task is ready to be started. 
		 */
		static public const TASK_READY:String = "TASK_READY";
		
		/**
		 * Defines when a task has been completed. 
		 */             
		static public const TASK_COMPLETE:String = "TASK_COMPLETE";
		
		/**
		 * Defines when a task is waiting for its ready state to change to true. 
		 */             
		static public const TASK_WAITING_FOR_READY:String = "TASK_WAITING_FOR_READY";
		
		
		/**
		 * Defines when a task is in either in the TaskController Queue or a TaskGroup queue. 
		 * @see com.developmentarc.core.controllers.TaskController
		 * @see com.developmentarc.core.datastructures.tasks.TaskGroup
		 */
		static public const TASK_QUEUED:String = "TASK_QUEUED";
		
		/**
		 * Defines when a task has been started.
		 */             
		static public const TASK_START:String = "TASK_START";
		
		/**
		 * Defines when a task has been paused. 
		 */             
		static public const TASK_PAUSE:String = "TASK_PAUSE";
		
		/**
		 * Defines when a task has been cancelled. 
		 */             
		static public const TASK_CANCEL:String = "TASK_CANCEL";
		
		/**
		 * Defines when a task has entered an error state. 
		 */             
		static public const TASK_ERROR:String = "TASK_ERROR";
		
		/**
		 * Defines when a task is set to ignore. 
		 */             
		static public const TASK_IGNORED:String = "TASK_IGNORED"
		
		/**
		 * @copy flash.events.Event
		 * 
		 */
		public function TaskEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}