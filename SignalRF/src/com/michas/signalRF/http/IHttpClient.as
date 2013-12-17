package com.michas.signalRF.http
{
	import com.michas.async.ITask;
	import com.michas.signalRF.IConnection;
	
	import flash.net.URLVariables;

	public interface IHttpClient
	{
		/**
		 * Initializes the Http Clients
		 * @param connection Connection
		 * 
		 */		
		function initialize(connection:IConnection):void;
		
		/**
		 * Makes an asynchronous http GET request to the specified url.
		 * @param url The url to send the request to.
		 * @param prepareRequest A callback that initializes the request with default values.
		 * @param isLongRunning Indicates whether it is a long running request
		 * @return IResponse object
		 * 
		 */		
		function get(url:String, prepareRequest:Function, isLongRunning:Boolean):ITask;
		
		/**
		 * Makes an asynchronous http POST request to the specified url.
		 * @param url The url to send the request to.
		 * @param prepareRequest A callback that initializes the request with default values.
		 * @param postData form url encoded data.
		 * @param isLongRunning Indicates whether it is a long running request
		 * @return IResponse object
		 * 
		 */		
		function post(url:String, prepareRequest:Function, postData:URLVariables, isLongRunning:Boolean):ITask;
		/*
		/// <summary>
		/// Initializes the Http Clients
		/// </summary>
		/// <param name="connection">Connection</param>
		void Initialize(IConnection connection);
		
		/// <summary>
		/// Makes an asynchronous http GET request to the specified url.
		/// </summary>
		/// <param name="url">The url to send the request to.</param>
		/// <param name="prepareRequest">A callback that initializes the request with default values.</param>
		/// <param name="isLongRunning">Indicates whether it is a long running request</param>
		/// <returns>A <see cref="T:Task{IResponse}"/>.</returns>
		[SuppressMessage("Microsoft.Naming", "CA1716:IdentifiersShouldNotMatchKeywords", MessageId = "Get", Justification = "Performs a GET request")]
		Task<IResponse> Get(string url, Action<IRequest> prepareRequest, bool isLongRunning);
		
		/// <summary>
		/// Makes an asynchronous http POST request to the specified url.
		/// </summary>
		/// <param name="url">The url to send the request to.</param>
		/// <param name="prepareRequest">A callback that initializes the request with default values.</param>
		/// <param name="postData">form url encoded data.</param>
		/// <param name="isLongRunning">Indicates whether it is a long running request</param>
		/// <returns>A <see cref="T:Task{IResponse}"/>.</returns>
		Task<IResponse> Post(string url, Action<IRequest> prepareRequest, IDictionary<string, string> postData, bool isLongRunning);
		*/
	}
}