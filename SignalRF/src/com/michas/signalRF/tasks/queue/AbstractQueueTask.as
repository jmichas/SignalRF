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
	
	import flash.events.EventDispatcher;
	import com.michas.signalRF.tasks.events.TaskEvent;
	
	[Event(name="taskReady",type="com.michas.signalRF.tasks.events.TaskEvent")]
	[Event(name="taskCompelte",type="com.michas.signalRF.tasks.events.TaskEvent")] 
	[Event(name="taskQueued",type="com.michas.signalRF.tasks.events.TaskEvent")] 
	[Event(name="taskStart",type="com.michas.signalRF.tasks.events.TaskEvent")] 
	[Event(name="taskPause",type="com.michas.signalRF.tasks.events.TaskEvent")] 
	[Event(name="taskCancel",type="com.michas.signalRF.tasks.events.TaskEvent")]
	[Event(name="taskError",type="com.michas.signalRF.tasks.events.TaskEvent")] 
	/**
	 * The AbstractTask is the base class to extend all Tasks from.
	 * The TaskController does not require a Task to extend from AbstractTask, 
	 * but looks for an ITask.  The AbstractTask is provided as a starting
	 * point to define basic types, events and implementations of the required
	 * interface API.
	 * 
	 * <p>The core structure of the Task follows the same basic design of a Flash
	 * Event.  Like an Event, the Task has a default type and priority that is
	 * used by the TaskController and the TaskGroup to manage and organize the order
	 * of the active tasks.</p>
	 * 
	 * @see com.developmentarc.core.controllers.TaskController
	 * @see com.developmentarc.core.datastructures.tasks.TaskGroup
	 */
	public class AbstractQueueTask extends EventDispatcher implements IQueueTask
	{
		/* STATIC PROPERTIES */
		/**
		 * Used as the flag for the current phase when a Task
		 * has been constructed.
		 */
		static public const TASK_CREATED:String = "TASK_CREATED";
		
		/* PROTECTED PROPERTIES */
		/**
		 * Stores the Task's internal current phase state value.
		 * This property is protected and intended to be accessible
		 * from extended Classes.  The value is publicly read-able
		 * via the phase getter.
		 */
		protected var currentPhase:String;
		
		/**
		 * Stores the list of overrides for the Task.
		 */
		protected var currentOverrides:Array;
		
		/* PRIVATE PROPERTIES */
		private var __type:String;
		private var __priority:int;
		private var __selfOverride:Boolean;
		private var __uid:Object;
		private var __isBlocker:Boolean;
		
		/**
		 * The Abstract Task constructor is used to define the base settings for the task.
		 * The only required argument is the type parameter which defines the Task type
		 * similar to an Event type.
		 *  
		 * @param type The Task type.
		 * @param priority The priority of the task, 0 is the highest priority, int.MAX_VALUE is the lowest.
		 * @param uid The unique identification id of the task used during the override process.
		 * @param selfOverride Defines of the task is self overriding.
		 * @param blocking Defines if the task is blocking.
		 * 
		 */
		public function AbstractQueueTask(type:String, priority:int = 5, uid:Object = null, selfOverride:Boolean = false, blocking:Boolean = false)
		{
			super(this);
			
			// set properties
			__type = type;
			__priority = priority;
			__uid = uid;
			__selfOverride = selfOverride;
			__isBlocker = blocking;
			
			currentOverrides = new Array();
			currentPhase = TASK_CREATED;
		}
		
		/**
		 * Defines the priority value of the task defined at construction.
		 * 0 is the highest priority, int.MAX_VALUE is the lowest.
		 * 
		 */
		public function get priority():uint
		{
			return __priority;
		}
		
		/**
		 * Determines if the Task blocks all other items
		 * in the TaskController.  If the Task is set as
		 * a blocking task, the controller will load no more
		 * items from the queue until this Task is complete,
		 * cancelled or errors. The default is false.
		 *  
		 * @return True if the group blocks, false if it does not.
		 * 
		 */
		public function get isBlocker():Boolean {
			return __isBlocker;
		}
		
		/**
		 * Defines the Task type. 
		 * 
		 */
		public function get type():String
		{
			return __type;
		}
		
		/**
		 * Defines if the task is in a ready state.
		 * 
		 */
		public function get ready():Boolean
		{
			return true;
		}
		
		
		/**
		 * Defines what phase the Task is currently in. When a task is
		 * created the default phase is TASK_CREATED.
		 * 
		 */
		public function get phase():String
		{
			return currentPhase;
		}
		
		/**
		 * Defines the currently applied overrides for the Task. Overrides
		 * are used by the TaskController and the TaskGroup to determine
		 * if the current task is responsible for removing/canceling existing
		 * tasks in the system.
		 * 
		 */
		public function get taskOverrides():Array
		{
			return currentOverrides;
		}
		
		/**
		 * Stores the unique identification value of the Task which was defined
		 * at construction.  The uid is used by the TaskController and TaskGroup
		 * to determine what if the Task should be overridden well self override is
		 * set to true. Tasks with matching uid's will be overridden.
		 * 
		 * @see com.developmentarc.core.controllers.TaskController
		 * @see com.developmentarc.core.datastructures.tasks.TaskGroup
		 * 
		 */
		public function get uid():Object {
			return __uid;
		}
		
		/**
		 * Defines if the Task is self-overriding when added to a TaskGroup
		 * or the TaskController. Tasks with matching uid's will be overridden.
		 * 
		 * @see com.developmentarc.core.controllers.TaskController
		 * @see com.developmentarc.core.datastructures.tasks.TaskGroup
		 * 
		 */
		public function get selfOverride():Boolean {
			return __selfOverride;
		}
		public function set selfOverride(value:Boolean):void {
			__selfOverride = value;
		}
		
		/**
		 * Starts the Task's functionality.  When the TaskController or
		 * TaskGroup is ready to start the Task, the start() method is
		 * called.  The AbstractTask sets the current Phase to TaskEvent.TASK_START
		 * and then dispatches a TaskEvent informing any listener that the Task
		 * has now been started.
		 * 
		 * <p>When extending the AbstractTask, this method must be overridden to
		 * define the functionality of the task.  It is recommended that calling
		 * super.start() is added as the last step of the overridden method so that
		 * the phase and TaskEvent is dispatched correctly.</p>
		 * 
		 */
		public function start():void
		{
			currentPhase = TaskEvent.TASK_START;
			dispatchEvent(new TaskEvent(TaskEvent.TASK_START));
		}
		
		/**
		 * Called when a previously started Task needs to be paused.  This is
		 * an optional method that must be overridden by the extending class
		 * to implement the pause ability. By default the pause() method sets
		 * the current phase to TaskEvent.TASK_PAUSE and then dispatches a
		 * TaskEvent informing any listener that the Task has now been paused.
		 * 
		 * <p>When extending the AbstractTask, this method must be overridden to
		 * define the functionality of the task.  It is recommended that calling
		 * super.pause() is added as the last step of the overridden method so that
		 * the phase and TaskEvent is dispatched correctly.</p>
		 * 
		 */
		public function pause():void
		{
			currentPhase = TaskEvent.TASK_PAUSE;
			dispatchEvent(new TaskEvent(TaskEvent.TASK_PAUSE));
		}
		
		/**
		 * Called when a previously started Task needs to be cancelled.  This is
		 * an optional method that must be overridden by the extending class
		 * to implement the cancel ability. By default the cancel() method sets
		 * the current phase to TaskEvent.TASK_CANCEL and then dispatches a
		 * TaskEvent informing any listener that the Task has now been paused.
		 * 
		 * <p>When extending the AbstractTask, this method must be overridden to
		 * define the functionality of the task.  It is recommended that calling
		 * super.cancel() is added as the last step of the overridden method so that
		 * the phase and TaskEvent is dispatched correctly.</p>
		 * 
		 */
		public function cancel():void
		{
			currentPhase = TaskEvent.TASK_CANCEL;
			dispatchEvent(new TaskEvent(TaskEvent.TASK_CANCEL));
		}
		
		/**
		 * Called when a Task is added to a queue (TaskController or TaskGroup).  
		 * This is an optional method that must be overridden by the extending class
		 * to implement the inQueue functionality. By default the inQueue() method sets
		 * the current phase to TaskEvent.TASK_QUEUED and then dispatches a
		 * TaskEvent informing any listener that the Task has now been paused.
		 * 
		 * <p>When extending the AbstractTask, this method must be overridden to
		 * define the functionality of the task.  It is recommended that calling
		 * super.inQueue() is added as the last step of the overridden method so that
		 * the phase and TaskEvent is dispatched correctly.</p>
		 * 
		 */
		public function inQueue():void
		{
			currentPhase = TaskEvent.TASK_QUEUED;
			dispatchEvent(new TaskEvent(TaskEvent.TASK_QUEUED));
		}
		
		/**
		 * Called when a task is waiting to be set to ready before starting.  This is
		 * an optional method that must be overridden by the extending class
		 * to implement the waiting ability. By default the inWaitingForReady() method sets
		 * the current phase to TaskEvent.TASK_WAITING_FOR_READY and then dispatches a
		 * TaskEvent informing any listener that the Task has now been paused.
		 * 
		 * <p>When extending the AbstractTask, this method must be overridden to
		 * define the functionality of the task.  It is recommended that calling
		 * super.inWaitingForReady() is added as the last step of the overridden method so that
		 * the phase and TaskEvent is dispatched correctly.</p>
		 * 
		 */
		public function inWaitingForReady():void
		{
			currentPhase = TaskEvent.TASK_WAITING_FOR_READY;
			dispatchEvent(new TaskEvent(TaskEvent.TASK_WAITING_FOR_READY));
		}
		
		/**
		 * Called when a previously started Task needs to be set to ignore.  This is
		 * an optional method that must be overridden by the extending class
		 * to implement the cancel ability. By default the ignore() method sets
		 * the current phase to TaskEvent.TASK_IGNORED and then dispatches a
		 * TaskEvent informing any listener that the Task has now been paused.
		 * 
		 * <p>When extending the AbstractTask, this method must be overridden to
		 * define the functionality of the task.  It is recommended that calling
		 * super.ignore() is added as the last step of the overridden method so that
		 * the phase and TaskEvent is dispatched correctly.</p>
		 * 
		 */
		public function ignore():void
		{
			currentPhase = TaskEvent.TASK_IGNORED;
			dispatchEvent(new TaskEvent(TaskEvent.TASK_IGNORED));
		}
		
		/**
		 * Called when a previously started Task is completed.  This is
		 * an optional method that must be overridden by the extending class
		 * to implement the complete ability. By default the complete() method sets
		 * the current phase to TaskEvent.TASK_COMPLETE and then dispatches a
		 * TaskEvent informing any listener that the Task has now been paused.
		 * 
		 * <p>When extending the AbstractTask, this method must be overridden to
		 * define the functionality of the task.  It is recommended that calling
		 * super.complete() is added as the last step of the overridden method so that
		 * the phase and TaskEvent is dispatched correctly.</p>
		 * 
		 */
		public function complete():void
		{
			currentPhase = TaskEvent.TASK_COMPLETE;
			dispatchEvent(new TaskEvent(TaskEvent.TASK_COMPLETE));
		}
		
		/**
		 * Called when a task recieves an error or generates an error.  By default 
		 * the error() method sets the current phase to TaskEvent.TASK_ERROR and then dispatches a
		 * TaskEvent informing any listener that the Task has now been paused.
		 * 
		 * <p>When extending the AbstractTask, this method must be overridden to
		 * define the functionality of the task.  It is recommended that calling
		 * super.error() is added as the last step of the overridden method so that
		 * the phase and TaskEvent is dispatched correctly.</p>
		 * 
		 */
		public function error():void
		{
			currentPhase = TaskEvent.TASK_ERROR;
			dispatchEvent(new TaskEvent(TaskEvent.TASK_ERROR));
		}
		
	}
}