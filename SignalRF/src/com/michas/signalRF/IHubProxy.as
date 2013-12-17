package com.michas.signalRF
{
	import com.michas.async.ITask;
	import com.michas.signalRF.hubs.Subscription;

	public interface IHubProxy
	{
		/**
		 * Sets state of the hub.
		 * @param name The name of the field.
		 * @return The value of the field
		 * 
		 */		
		function setState(name:String, value:String):void;
		
		/**
		 * Gets state of the hub.
		 * @return The value of the field
		 * 
		 */	
		function getState(name:String):String;
		
		/**
		 * Executes a method on the server side hub asynchronously.<br/>
		 * Most of the time you should use invoke$T since this is essentially a convenience method for <code>invoke$T(method, Object, false, args)</code>
		 * @param method The name of the method.
		 * @param args The arguments
		 * @return A task that represents when invocation returned.
		 * 
		 */		
		function invoke(method:String, ...args):ITask;
		
		/**
		 * Executes a method on the server side hub asynchronously.<br/>
		 * If you are using SignalR.Backbone on the server side you can call Create, Find, FindAll, Update and Destroy by passing the args as JSON stringified strings. The server side code expects a JSON string as input, the types will be proerly cast when returned.
		 * <br/><br/>
		 * You may be better off creating your own methods on the server hub to be invoked by the Flex/AS3 client separate from the SignalR.Backbone methods..
		 * @param method The name of the method.
		 * @param args Comma delimited arguments. These must match the parameters expected by the server hub method being invoked. If using SignalR.Backbone on the server side where your hub is inheriting from BackboneModelHub<> you will need to pass arguments as JSON strings.
		 * @param $T The type of result returned from the hub
		 * @param returnsCollection Whether the server method returns a collection, if it does each item will be cast to $T
		 * @return A task that represents when invocation returned.
		 * 
		 */		
		function invoke$T(method:String, $T:Class, returnsCollection:Boolean = false, ...args):ITask;
		
		/**
		 * Registers an event for the hub.
		 * @param eventName The name of the event
		 * @return A Subscription object.
		 * 
		 */		
		function subscribe(eventName:String):Subscription;
		
		function on(eventName:String, $T:Class, onData:Function):void
		function off(eventName:String):void;
			/*
		/// <summary>
		/// Gets or sets state on the hub.
		/// </summary>
		/// <param name="name">The name of the field.</param>
		/// <returns>The value of the field</returns>
		JToken this[string name] { get; set; }
		
		/// <summary>
		/// Executes a method on the server side hub asynchronously.
		/// </summary>
		/// <param name="method">The name of the method.</param>
		/// <param name="args">The arguments</param>
		/// <returns>A task that represents when invocation returned.</returns>
		Task Invoke(string method, params object[] args);
		
		/// <summary>
		/// Executes a method on the server side hub asynchronously.
		/// </summary>
		/// <typeparam name="T">The type of result returned from the hub</typeparam>
		/// <param name="method">The name of the method.</param>
		/// <param name="args">The arguments</param>
		/// <returns>A task that represents when invocation returned.</returns>
		Task<T> Invoke<T>(string method, params object[] args);
		
		/// <summary>
		/// Registers an event for the hub.
		/// </summary>
		/// <param name="eventName">The name of the event</param>
		/// <returns>A <see cref="Subscription"/>.</returns>
		Subscription Subscribe(string eventName);
		
		/// <summary>
		/// Gets the serializer used by the connection.
		/// </summary>
		JsonSerializer JsonSerializer { get; }
		
		*/
	}
}