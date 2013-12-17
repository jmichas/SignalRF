package com.michas.signalRF.http
{
	import flash.utils.Dictionary;

	public interface IRequest
	{
		function get userAgent():String;
		function set userAgent(agent:String):void;
		function get accept():String;
		function set accept(v:String):void;
		function abort():void;
		function setRequestHeaders(headers:Dictionary):void;
		
		/*
		/// <summary>
		/// The user agent for this request.
		/// </summary>
		string UserAgent { get; set; }
		
		/// <summary>
		/// The accept header for this request.
		/// </summary>
		string Accept { get; set; }
		
		/// <summary>
		/// Aborts the request.
		/// </summary>
		void Abort();
		
		/// <summary>
		/// Set Request Headers
		/// </summary>
		/// <param name="headers">request headers</param>
		void SetRequestHeaders(IDictionary<string, string> headers);
		*/
	}
}