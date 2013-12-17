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
	/*
	import com.developmentarc.core.datastructures.utils.PriorityQueue;
	import com.developmentarc.core.tasks.events.TaskEvent;
	import com.developmentarc.core.tasks.tasks.ITask;
	*/
	import flash.events.EventDispatcher;
	import com.michas.signalRF.tasks.events.TaskEvent;
	
	/**
	 * The TaskGroup is a data structure that allows a set of tasks
	 * to be grouped together as a set.  The TaskGroup can then be
	 * added to the TaskController and all of the grouped task will
	 * be exectued first before the next task in the controller is
	 * processed.
	 * 
	 * <p>When an override is provided to the task controller, the
	 * task group acts as a parent type and the task group will
	 * remove all tasks if the provided override matches the group
	 * type.  The individual type of the task is ignored in this
	 * case.</p>
	 * 
	 * <p>Tasks added to the group can override the same was as if they were
	 * added directly to the TaskController. Upon adding a task, the TaskGroup
	 * will evaluate the tasks overrides and the tasks selfOverrding boolean 
	 * and will take appropriate action.  The functionality is similar to the
	 * TaskController's override mechinism.
	 * </p>
	 * 
	 * <p>TaskGroups can NOT be added to other TaskGroups at this time. A generic error will
	 * be thrown if this occurs</p>
	 * 
	 * <p>Note: Once a TaskGroup has been added to the TaskController and queued, 
	 * the TaskGroup will no longer accept additional Task and will throw a generic error.
	 * </p>
	 * 
	 * @see com.developmentarc.core.controllers.TaskController
	 * 
	 * @author James Polanco
	 * 
	 */
	public class QueueTaskGroup extends EventDispatcher implements IQueueTaskGroup
	{
		
		
		/* PUBLIC PROPERTIES */
		/**
		 * The default phase value of a group when it is first constructed
		 * but not added to the TaskController. 
		 */
		public static const GROUP_NOT_QUEUED:String = "GROUP_NOT_QUEUED";
		
		/* PROTECTED PROPERTEIS */
		
		/**
		 * The current tasks that have been added to the Group but have not
		 * been started() yet. 
		 */
		protected var taskQueue:PriorityQueue;
		
		/**
		 * The tasks that have been started, cancelled, ignored or errored out. 
		 */             
		protected var processedQueue:PriorityQueue;
		
		/**
		 * The current phase of the group. 
		 */
		protected var currentPhase:String = GROUP_NOT_QUEUED;
		
		/* PRIVATE PROPERTIES */
		private var __type:String;
		private var __groupOverrides:Array;
		private var __priority:int;
		private var __uid:Object;
		private var __selfOverride:Boolean;
		private var __isBlocker:Boolean;
		
		/**
		 * Constructor.  Sets the groups type and priority.
		 * 
		 * @param type The type of Task
		 * @param priority The priority of the TaskGroup inside of the TaskController. Default is 5. Lower the number the higher the priority.
		 * @param uid The id set to this group. uid can be of any type. Default is null
		 * @param selfOverride Boolean indicating if the TaskGroup can override other TaskGroups of the same type with same uid. Default false
		 * 
		 */
		public function QueueTaskGroup(type:String, priority:int = 5, uid:Object = null, selfOverride:Boolean = false, blocking:Boolean = false)
		{
			super(this);
			
			taskQueue = new PriorityQueue();
			processedQueue = new PriorityQueue();
			
			__groupOverrides = new Array();
			__type = type;
			__priority = priority;
			__uid = uid;
			__selfOverride = selfOverride
			__isBlocker = blocking;
		}
		
		/**
		 * The current type of TaskGroup. The type defines how task
		 * overrides are applied when the group is in the queue.  
		 * If a task or task group overrides the matching type of 
		 * the group, the entire group is removed from the queue.
		 *  
		 * @return  The task type.
		 * 
		 */
		public function get type():String
		{
			return __type;
		}
		
		/**
		 * Determines if the TaskGroup blocks all other items
		 * in the TaskController.  If the TaskGroup is set as
		 * a blocking task, the controller will load no more
		 * items from the queue until this group is complete,
		 * cancelled or errors. The default is false.
		 *  
		 * @return True if the group blocks, false if it does not.
		 * 
		 */
		public function get isBlocker():Boolean {
			return __isBlocker;
		}
		
		/**
		 * The priority value of the TaskGroup.  0 is the highest
		 * priority and uint.MAX_VALUE is the lowest priority.
		 *  
		 * @return 
		 * 
		 */
		public function get priority():uint
		{
			return __priority;
		}
		/**
		 * Id of the group instance. Used in applying self overrides.
		 * 
		 * @return id of the group
		 */
		public function get uid():Object {
			return __uid;
		}
		
		/**
		 * Determines if TaskGroup contains tasks or not.
		 *  
		 * @return True if tasks exist, false if not.
		 * 
		 */
		public function get hasTask():Boolean
		{
			return taskQueue.hasItems;
		}
		
		/**
		 * An array of types of tasks / task groups that this
		 * task group should override in the TaskController. When
		 * a task group is added to the controller, the controller
		 * uses the taskOverrides list to determine what tasks or
		 * other groups should be removed from the current queue.
		 *  
		 * @param value
		 * 
		 */
		public function get taskOverrides():Array
		{
			return __groupOverrides;
		}
		
		public function set taskOverrides(value:Array):void
		{
			__groupOverrides = value;
		}
		
		/**
		 * <p>Adds a single task to the task group.  The added
		 * task is stored by its priority within the task
		 * group.</p>
		 * 
		 * <p>A group can NOT be added to another group. Error will be thrown.</p>
		 * 
		 * <p>Tasks can only be added if the group is not already in the queue. Error will be thrown.</p>
		 * 
		 * @param task New task to be added to group.
		 * 
		 */
		public function addTask(task:IQueueTask):void
		{
			// Throw error if a group is added to a this group
			if(task is IQueueTaskGroup) {
				throw new Error("TaskGroups  can not be added to other TaskGroups");
			}
			
			// Throw error if group is not in the base phase
			if(currentPhase != GROUP_NOT_QUEUED) {
				throw new Error("No task can be added one group is no longer in the GROUP_NOT_QUEUED phase.  Current phase is " + currentPhase);
			}
			
			// Apply overrides
			// If overrides dont override this task add task
			if(applyOverrides(task)) { 
				// Determine priority and placement
				taskQueue.addItem(task, task.priority);
				// mark task as queued
				task.inQueue();
			}
			else {
				// Trigger ignore on task
				task.ignore();
			}                       
		}
		
		/**
		 * <p>
		 * Used to find and remove any tasks in the current group
		 * queue that are overriden by a new task that has been
		 * added to the group.
		 * </p>
		 * <p>
		 * If the new task is selfOverriding two scenarios will play out.
		 * <ul>
		 *      <li>If new task has same type as a task in the queue but with a differnt uid, the existing task removed and canceled. The new task is then added.</li>
		 *  <li>If new task has same type and the same uid as one in the queue, the new task is ignored and not added to the queue</li>
		 * </ul>
		 * </p>
		 * @param newTask New Task to be added to queue
		 * 
		 * @return Boolean True if newTasks overrides were processed,otherwise false
		 */
		protected function applyOverrides(newTask:IQueueTask):Boolean
		{
			var overrides:Array = newTask.taskOverrides;
			
			// No overrides and no not selfoverriding
			if(overrides.length < 1 && !newTask.selfOverride) return true; 
			
			var newList:Array = new Array();
			var match:Boolean;
			// Only items left in the queue - assumption is proccessed queue is empty if we are
			// applying overrides.
			var itemList:Array = taskQueue.items;
			
			// Handle self override
			// Loop over all tasks looking for self override
			if(newTask.selfOverride) {
				match = false;
				for each(var task:IQueueTask in itemList)
				{
					// If match not found and task types are the same
					if(newTask.type == task.type) {
						// If tasks has same uid, mark the newTask so we dont keep it
						if(newTask.uid == task.uid) {
							// Dont keep the newTask, exit now so we dont change the queue
							return false;
						}
						else {
							// Found a match, cancel it
							if(task is IQueueTask) IQueueTask(task).cancel();
						}
					}
						// Only add task that are not active
					else {
						newList.push(task);
						match = true;
					}
				}       
			}
			// Set new itemList after removing selfoverrides, reset newList
			itemList = (match) ? newList : itemList;
			newList = new Array();
			
			// Handle Task overrides
			var len:int = overrides.length; 
			for each(task in itemList)
			{
				// Reset match to not found
				match = false;
				// Loop over all overrides
				for(var i:uint = 0; i < len; i++) 
				{ 
					// If task has same type as override - cancel it!
					if(task.type == overrides[i]) 
					{
						// found a match, cancel it
						match == true; 
						if(task is IQueueTask) IQueueTask(task).cancel();
					}
				}
				// Only add task if a match was not found
				if(!match) {
					newList.push(task);
				}
			}
			// Update to the stripped list
			var newTaskQueue:PriorityQueue = new PriorityQueue();
			
			// Create new task queue based on new list array
			for each(task in newList) {
				newTaskQueue.addItem(task, task.priority);
			}
			// Set new queue to task queue
			taskQueue = newTaskQueue;
			
			// Return, we are keeping the new task
			return true;
		}
		/**
		 * The tasks value is the active array of tasks
		 * within the task group.  When setting this value
		 * the tasks are ordered by priority within the
		 * task group, and the initial order of the provided
		 * array is ignored.
		 *  
		 * @param value
		 * 
		 */
		public function set tasks(value:Array):void
		{
			for each(var task:IQueueTask in value)
			{
				taskQueue.addItem(task, task.priority);
			}
		}
		/**
		 * Returns all tasks still in queue or that have been proccessed
		 */
		public function get tasks():Array
		{
			
			return taskQueue.items.concat(processedQueue.items);
		}
		
		/**
		 * Returns the current phase of the TaskGroup, such as started, etc. 
		 * 
		 * @return The current phase of the TaskGroup.
		 * 
		 */
		public function get phase():String
		{
			return currentPhase;
		}
		
		/**
		 * TaskGroups are always ready and will return true
		 */
		public function get ready():Boolean{
			return true;
		}
		
		/**
		 * Defines whether the group is self-overriding or not. When a group
		 * is self-overriding then when the group is added to the TaskController
		 * the TaskController will determine if the group already exists in the queue
		 * and if so then it will be removed from the queue.
		 *  
		 * @return True if self-overriding or false if not.
		 *
		 */
		public function get selfOverride():Boolean {
			return __selfOverride;
		}
		public function set selfOverride(value:Boolean):void {
			__selfOverride = value;
		}
		
		/**
		 * Removes all instances of a specific task from the group.
		 * When removed the task's cancel() method is called to
		 * allow listeners the ability to handle the removal.
		 * 
		 * @param task The task to remove.
		 * 
		 */
		public function removeTask(task:IQueueTask):void
		{
			// Remove from taskQueue if it is inside of queue
			if(!taskQueue.removeItem(task)) {
				processedQueue.removeItem(task);
			}
			// Cancel task if it has not completed or already been canceled
			if(task.phase != TaskEvent.TASK_CANCEL && task.phase != TaskEvent.TASK_COMPLETE) {
				task.cancel();
			}
		}
		
		/**
		 * Removes all tasks from the group. When removed 
		 * the task's cancel() method is called on all unproccessed 
		 * tasks to allow listeners the ability to handle the removal.
		 * All proccessed tasks will simply be removed from the group.
		 * No further action is taken.
		 * 
		 */
		public function removeAllTasks():void
		{
			for each(var task:IQueueTask in this.tasks) {
				removeTask(task);
			}
		}
		
		/**
		 * Returns the next task in the group with the highest
		 * priority task first.  This method removes the task
		 * from the task queue and addes to a proccessed queue.
		 *  
		 * @return The next task in the group.
		 * 
		 */
		public function next():IQueueTask
		{
			// Remove from queue and hold on to it in the processed queue
			var task:IQueueTask = taskQueue.next();
			processedQueue.addItem(task);
			
			// Listen for complete or cancel events
			task.addEventListener(TaskEvent.TASK_COMPLETE, handleTaskEvent);
			task.addEventListener(TaskEvent.TASK_CANCEL, handleTaskEvent);
			task.addEventListener(TaskEvent.TASK_ERROR, handleTaskEvent);
			
			return task;
		}
		
		/**
		 * Returns the index of a task in the taskQueue. Tasks
		 * that have been proccessed will not be found. Check 
		 * the phase of a task if you are sure a task is part of the group.
		 * 
		 * @param task
		 * @return 0 or greater if task is found, otherwise -1
		 */
		public function getTaskIndex(task:IQueueTask):int {
			// Loop through all tasks, if the same task is found
			// return index
			for(var i:uint=0;i<=tasks.length;i++) {
				if(tasks[i] == task) {
					return i; 
				}
			}
			// Return -1 if the task is NOT found
			return -1;
		}
		/**
		 * Method is used to change groups phase to start and dispath event.
		 * Method should NOT be called by anyone but the TaskController.
		 */
		public function start():void {
			currentPhase = TaskEvent.TASK_START;
			dispatchEvent(new TaskEvent(TaskEvent.TASK_START));
		}
		/**
		 * Method is used to change groups phase to pause and dispath event.
		 * Method should NOT be called by anyone but the TaskController.
		 */
		public function pause():void {
			currentPhase = TaskEvent.TASK_PAUSE;
			dispatchEvent(new TaskEvent(TaskEvent.TASK_PAUSE));
		}
		/**
		 * Method is used to change groups phase to canel and dispath event.
		 * The phase is first changed and then all tasks in the group are canceled before
		 * cancel event is dispatched (TestEvent.TASK_CANCEL).
		 * 
		 * Method should NOT be called by anyone but the TaskController.
		 */
		public function cancel():void {
			// Set phoase to Cancel
			currentPhase = TaskEvent.TASK_CANCEL;
			
			// Cancel all items in group
			for each(var task:IQueueTask in this.tasks) {
				// Only tasks that have not completed or been canceled
				if(task.phase != TaskEvent.TASK_CANCEL || task.phase != TaskEvent.TASK_COMPLETE) {
					task.cancel();
				}
			}
			// Dispatch Cancel after all task cancel has been executed
			// TODO - Maybe Cancel should only fire when all Tasks have dispatched their cancel events?
			dispatchEvent(new TaskEvent(TaskEvent.TASK_CANCEL));
			
		}
		/**
		 * Method is used to change groups phase to queued and dispath event.
		 * Method should NOT be called by anyone but the TaskController.
		 */
		public function inQueue():void {
			currentPhase = TaskEvent.TASK_QUEUED;
			dispatchEvent(new TaskEvent(TaskEvent.TASK_QUEUED));
		}
		/**
		 * Method is used to change groups phase to wait for ready and dispath event.
		 * Method should NOT be called by anyone but the TaskController.
		 */
		public function inWaitingForReady():void {
			currentPhase = TaskEvent.TASK_WAITING_FOR_READY;
			dispatchEvent(new TaskEvent(TaskEvent.TASK_WAITING_FOR_READY));
		}
		/**
		 * Method is used to change groups phase to ignore and dispath event.
		 * Method should NOT be called by anyone but the TaskController.
		 */
		public function ignore():void
		{
			currentPhase = TaskEvent.TASK_IGNORED;
			dispatchEvent(new TaskEvent(TaskEvent.TASK_IGNORED));
		}
		
		/**
		 * Method handles group tasks that have been completed, cancel or errored.
		 * If the no more tasks are in queue, a complete event is dispatched.
		 * 
		 * @param event
		 */
		protected function handleTaskEvent(event:TaskEvent):void
		{
			var task:IQueueTask = IQueueTask(event.currentTarget);
			
			// Remove listner for complete, cancel, error events
			task.removeEventListener(TaskEvent.TASK_COMPLETE, handleTaskEvent);
			task.removeEventListener(TaskEvent.TASK_CANCEL, handleTaskEvent);
			task.removeEventListener(TaskEvent.TASK_ERROR, handleTaskEvent);
			
			switch(event.type)
			{
				case TaskEvent.TASK_COMPLETE:
				case TaskEvent.TASK_CANCEL:
					if(!this.taskQueue.hasItems) {
						var stillActives:Boolean;
						// Loop through all proccessed tasks and verify they are either complete or canceled
						for each(var proccessed:IQueueTask in this.processedQueue.items) {
							if(proccessed.phase != TaskEvent.TASK_CANCEL && proccessed.phase != TaskEvent.TASK_COMPLETE) {
								stillActives = true;
							}
						}
						// If no actives dispatch complete
						if(!stillActives) {
							currentPhase = TaskEvent.TASK_COMPLETE;
							dispatchEvent(new TaskEvent(TaskEvent.TASK_COMPLETE));
						}
					}
					break
				
				case TaskEvent.TASK_ERROR: 
					currentPhase = TaskEvent.TASK_ERROR;
					dispatchEvent(new TaskEvent(TaskEvent.TASK_ERROR));
					
					break
				
			}
		}
	}
}