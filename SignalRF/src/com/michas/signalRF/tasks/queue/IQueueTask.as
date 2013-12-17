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
	import flash.events.IEventDispatcher;
	
	/**
	 * The ITask interface allows the implemented class to be treated
	 * as a Task object that can be used within the TaskController or
	 * the TaskGroup.
	 *  
	 * @author Aaron Pedersen
	 * 
	 */
	public interface IQueueTask extends IEventDispatcher
	{
		/**
		 * Used to define the ready state of the Task. If true the task
		 * is ready to be started, if false the task is not ready to be
		 * started.
		 *  
		 * @return True for ready, false for not ready.
		 * 
		 */
		function get ready():Boolean;
		
		/**
		 * Returns the current phase of of the Task.
		 *  
		 * @return The string constant that defines the current Task phase.
		 * 
		 */
		function get phase():String;
		
		/**
		 * Returns the priority value of the Task.  Zero being the highest
		 * priority and uint.MAX_VALUE being the lowest.
		 *  
		 * @return The priority value of the task.
		 * 
		 */
		function get priority():uint;
		
		/**
		 * Returns the type value of the Task. This defines what type of task
		 * the object represents.  This is similar to the Event.type property.
		 *  
		 * @return The type of task.
		 * 
		 */
		function get type():String;
		
		/**
		 * Returns an array of Task types that this task will override when added
		 * to the TaskController or a TaskGroup.
		 *  
		 * @return Array of Task types.
		 * 
		 */
		function get taskOverrides():Array;
		
		/**
		 * A unique identification value assigned to the task.  This value allows
		 * for self overriding task to know if they are both the same type and 
		 * identification.
		 *  
		 * @return Object that represents the unique id.
		 * 
		 */
		function get uid():Object;
		
		/**
		 * Defines if the Task is a blocking task.  A Blocking task prevents any other
		 * tasks in the queue from executing until this task is completed.
		 *  
		 * @return True if blocker, false if not.
		 * 
		 */
		function get isBlocker():Boolean;
		
		/**
		 * Defines of if the Task overrides the same type of task that already have
		 * been added to a queue.  When a task is self-overriding and is added to the
		 * Task Controller or Task Group, the controller/group reviews the existing task
		 * queue and then removes any exisiting task that have the same type and uid as
		 * the new task that is being added.
		 * 
		 * 
		 */
		function get selfOverride():Boolean;
		
		function set selfOverride(value:Boolean):void;
		
		/**
		 * Used to start the task when it becomes active. 
		 * 
		 */
		function start():void;
		
		/**
		 * Used to pause a started task. 
		 * 
		 */
		function pause():void;
		
		/**
		 * Used to cancel a task. 
		 * 
		 */
		function cancel():void;
		
		/**
		 * Used to set the task state to queued. 
		 * 
		 */
		function inQueue():void;
		
		/**
		 * Used to put the Task in waiting for ready mode. 
		 * 
		 */
		function inWaitingForReady():void;              
		
		/**
		 * Used to put the task in ignore mode. 
		 * 
		 */
		function ignore():void;
		
	}
}