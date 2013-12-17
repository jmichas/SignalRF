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
	//import com.developmentarc.core.tasks.tasks.ITask;
	
	/**
	 * The ITaskGroup interface is used for collections that hold
	 * tasks.  The default implementation using the ITaskGroup is
	 * the TaskGroup Class.
	 * 
	 * @see com.developmentarc.core.datastructures.tasks.TaskGroup
	 * 
	 * @author Aaron Pedersen
	 * 
	 */
	public interface IQueueTaskGroup extends IQueueTask
	{
		/**
		 * Defines if the current group has any tasks in the queue.
		 *  
		 * @return True if tasks exist, false if not.
		 * 
		 */
		function get hasTask():Boolean
		
		/**
		 * Used to add a task to the task group implementation.
		 *  
		 * @param task The task to add to the group.
		 * 
		 */
		function addTask(task:IQueueTask):void
		
		/**
		 * Used to add an array of tasks to the group.
		 *  
		 * @param value An array of ITask items.
		 * 
		 */
		function set tasks(value:Array):void
		
		/**
		 * Returns an Array of ITasks that are in the group.
		 *  
		 * @return Array of ITask items.
		 * 
		 */
		function get tasks():Array
		
		/**
		 * Removes the requested task from the group if the task exists. 
		 * 
		 * @param task The task to remove.
		 * 
		 */
		function removeTask(task:IQueueTask):void
		
		/**
		 * Used to remove all the ITasks from the group. 
		 * 
		 */
		function removeAllTasks():void
		
		/**
		 * Looks up and returns the next ITask in the group.
		 *  
		 * @return The next ITask in the group.
		 * 
		 */
		function next():IQueueTask
		
	}
}