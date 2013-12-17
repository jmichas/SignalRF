
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
package com.michas.signalRF.tasks.queue

{
	import com.michas.signalRF.tasks.events.TaskEvent;
	
	/*
	import com.developmentarc.core.datastructures.utils.HashTable;
	import com.developmentarc.core.datastructures.utils.PriorityQueue;
	import com.developmentarc.core.tasks.events.TaskEvent;
	import com.developmentarc.core.tasks.groups.IQueueTaskGroup;
	import com.developmentarc.core.tasks.tasks.IQueueTask;
	*/
	
	import flash.events.EventDispatcher;
	import com.michas.signalRF.tasks.events.TaskEvent;
	
	/**
	 * The TaskController class is the main manager of the task system framework. This class is 
	 * responsible for managing current and new tasks in a task system. The class is used as an 
	 * instance to allow for multiple task to run in the same application.
	 * 
	 * <p>The TaskController, by default, is not a singleton and the goal of the framework is to 
	 * allow multiple Task systems to be running in any given application. For example, one task 
	 * system can be created to manage server requests while another can be used to control internal 
	 * business operations. To create multiple systems, simply create multiple instances of the 
	 * TaskController. </p>
	 * 
	 * <p>To use the TaskController as a singleton, utilize the SingletonFactory utility class within
	 * the DevelopmentArc Core library.</p>
	 * 
	 * <p>The controller starts a set of tasks based on the active task limit set on the controller. 
	 * By default 2 tasks can be concurrently active within the controller, however this is configurable 
	 * in the task controller instance. When a task is complete the controller will remove the task 
	 * from the active list and start the next one in the queue, if any. </p>
	 * 
	 * The TaskController is also responsible for managing overrides. When a task is added to the controller, 
	 * the tasks overrides are applied removing any existing tasks from the queue that matches an override. 
	 * Overrides do pertain to tasks that are currently active, those will be canceled and removed from the queue. 
	 * Next the task is added to the internal priority queue in the proper order. </p>
	 * 
	 * @author Aaron Pedersen
	 * 
	 */
	public class TaskController extends EventDispatcher
	{
		/**
		 * Stores the current Tasks and TaskGroups within the TaskController. 
		 */
		protected var taskQueue:PriorityQueue;
		
		/**
		 * Stores the active Tasks and TaskGroups that are have been started by the controller. 
		 */             
		protected var activeTasks:HashTable;
		
		/**
		 * Stores IQueueTasks that returned false for the ready value when attempted to be started by the controller. 
		 */             
		protected var notReadyQueue:HashTable;
		
		private var __activeTaskLimit:uint = 2;
		private var __isBlocked:Boolean = false;
		
		/**
		 * Constructor. 
		 * 
		 */
		public function TaskController()
		{
			super(this);
			
			taskQueue = new PriorityQueue();
			activeTasks = new HashTable();
			notReadyQueue = new HashTable();
		}
		
		
		/**
		 * Contains the number of tasks that can be run at the same time.  The defaulf value is 2 tasks.
		 *  
		 * @param value The number of simultaneous tasks to be run, 1 through uint.MAX_VALUE.
		 * 
		 */
		public function get activeTaskLimit():uint
		{
			return __activeTaskLimit;
		}
		
		public function set activeTaskLimit(value:uint):void
		{
			__activeTaskLimit = value;
		}
		
		/**
		 * When an IQueueTask (task, task group, etc.) is ready to be added to the controller this
		 * method is called. addTask() puts the item at the end of the queue and then applies
		 * any overrides assigned by the IQueueTask.  If the current queue contains overrides then
		 * the override conflict logic is applied to determine if the added item is kept and the
		 * existing conflicting task is removed or if the existing task is kept and the new one
		 * is discarded.
		 * 
		 * @param task The IQueueTask to add to the controller.
		 * 
		 */
		public function addTask(task:IQueueTask):void
		{
			// apply overrides
			// if overrides dont override this task add task
			if(applyOverrides(task)) { 
				
				// determine priority and placement
				task.inQueue();
				taskQueue.addItem(task, task.priority);
			}
			else {
				// Trigger Ignore on task
				task.ignore();
			}
			// call next, to check queue state
			next();
		}
		
		/**
		 * <p>
		 * Used to find and remove any tasks in the current
		 * queue that are overriden by a new task that has been
		 * added to the controller. This includes those tasks that are active.
		 * </p>
		 * <p>
		 * If the new task is selfOverriding two scenarios will play out.
		 * 
		 * <ul>
		 *      <li>If new task has same type and a different uid as a task in the queue or active queue the existing task is removed and canceled, the new task is then added to the queue.</li>
		 *  <li>If new task has same type and the same uid as a queued or active task, the new task is ignored and not added to they system.</li>
		 * </ul>
		 * </p>
		 * @param newTask New Task to be added to queue
		 * 
		 * @return Boolean True if newTasks overrides were processed,otherwise false
		 */
		
		protected function applyOverrides(newTask:IQueueTask):Boolean
		{
			var overrides:Array = newTask.taskOverrides;
			
			//// no overrides and no not selfoverriding
			if(overrides.length < 1 && !newTask.selfOverride) return true; 
			
			// loop over and find all the matched type
			var newList:Array = new Array();
			var match:Boolean;
			
			var itemList:Array = taskQueue.items.concat(activeTasks.getAllKeys());
			
			// Handle self override 
			// Loop over all tasks looking for self override
			if(newTask.selfOverride) {
				match = false;
				for each(var task:IQueueTask in itemList)
				{
					if(newTask.type == task.type) {
						// Already one in the queue with same type and uid, disregard new task
						if(newTask.uid == task.uid) {
							return false;
						}
						else {
							// Found a match, cancel it
							if(task is IQueueTask) IQueueTask(task).cancel();
							
						}
					}
						// Only add task that are not active
					else if(!activeTasks.containsKey(task)) {
						newList.push(task);
						match = true;
					}
				}       
			}
			// Set new itemList after removing selfoverrides, reset newList
			itemList = (match) ? newList : itemList;
			newList = new Array();
			
			var len:int = overrides.length; 
			// Task overrides - only if new task is not disregarded based on selfoverrides
			for each(task in itemList)
			{
				match = false;
				for(var i:uint = 0; i < len; i++) 
				{ 
					if(task.type == overrides[i]) 
					{
						// found a match, cancel it
						match == true; 
						// Cancel task          
						IQueueTask(task).cancel();
					}
				}
				// Only add task that are not active
				if(!match && !activeTasks.containsKey(task)) {
					
					newList.push(task);
				}
			}
			// update to the stripped list
			
			var newTaskQueue:PriorityQueue = new PriorityQueue();
			
			for each(task in newList) {
				newTaskQueue.addItem(task, task.priority);
			}
			taskQueue = newTaskQueue;
			
			return true;
		}
		
		/**
		 * Checks to see if any task slots are available, if so then the next
		 * task in the queue is added.  This method is called when tasks are added 
		 * or change state.  This method is protected to prevent developers from
		 * directly calling next() and instead letting the controller process the
		 * queue based on the defined logic. 
		 * 
		 */
		protected function next():void
		{
			// make sure we have tasks, if not exit
			if(__isBlocked || !taskQueue.hasItems) return;
			
			// see if we can handle a new task
			if(activeTasks.length < __activeTaskLimit)
			{
				// we need to take action, first check ready queue then go to task queue
				var nextTask:IQueueTask = IQueueTask(taskQueue.peek());
				
				// If nextTask is canceled pop from queue
				
				if(nextTask.phase == TaskEvent.TASK_CANCEL) {
					taskQueue.next();
					// Recursion, call this method again for next item
					this.next();
					return;
				}
				// determine if it is a task or task base
				var task:IQueueTask;
				
				if(nextTask is IQueueTaskGroup)
				{
					// If no more tasks are in the group,pop group from queue
					// and call next and return;
					if(!IQueueTaskGroup(nextTask).hasTask) { 
						taskQueue.next();
						this.next();    
						return;
					}
					
					// Mark group as in queue
					if(nextTask.phase != TaskEvent.TASK_START) {
						nextTask.start();
					}
					
					task = IQueueTaskGroup(nextTask).next();
					
					
				} else {
					task = IQueueTask(taskQueue.next());
				}
				
				
				// determine if the tasks are ready
				if(task.ready)
				{
					// determine if the task is blocking, is so set up the block
					__isBlocked = task.isBlocker;
					
					// start the task and add it to the active task list
					task.addEventListener(TaskEvent.TASK_COMPLETE, handleTaskEvent);
					task.addEventListener(TaskEvent.TASK_CANCEL, handleTaskEvent);
					task.addEventListener(TaskEvent.TASK_ERROR, handleTaskEvent);
					activeTasks.addItem(task, true);
					task.start();
					// see if we can add more tasks
					if(activeTasks.length < __activeTaskLimit) next();
				} else {
					// the task is not ready, add to the not ready queue
					task.addEventListener(TaskEvent.TASK_READY, handleTaskEvent);
					notReadyQueue.addItem(task, true);
					task.inWaitingForReady();
					next();
				}
			}
		}
		
		/**
		 * Called when a task changes state, such as complete or error.  Handles
		 * unregistering event listening, checks to see if the queue was blocked and
		 * then calls next() to continue the process.
		 *  
		 * @param event The TaskEvent dispatched from the watched IQueueTask instance.
		 * 
		 */
		protected function handleTaskEvent(event:TaskEvent):void
		{
			var task:IQueueTask = IQueueTask(event.currentTarget);
			
			switch(event.type)
			{
				case TaskEvent.TASK_CANCEL:
				case TaskEvent.TASK_COMPLETE:
				case TaskEvent.TASK_ERROR:
					// remove from the active queue
					activeTasks.remove(task);
					task.removeEventListener(TaskEvent.TASK_COMPLETE, handleTaskEvent);
					task.removeEventListener(TaskEvent.TASK_CANCEL, handleTaskEvent);
					task.removeEventListener(TaskEvent.TASK_ERROR, handleTaskEvent);
					
					// unblock, if the task is a blocker
					if(task.isBlocker) __isBlocked = false;
					
					next();
					break;
				
				case TaskEvent.TASK_READY:
					// remove from the not ready task, add to the front of the line and call next
					notReadyQueue.remove(task);
					task.removeEventListener(TaskEvent.TASK_READY, handleTaskEvent);
					taskQueue.addItem(task, 1); // set to one to override all but zero
					next();
					break;
			}
		}
		
	}
}