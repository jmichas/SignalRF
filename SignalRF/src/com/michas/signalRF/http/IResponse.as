package com.michas.signalRF.http
{
	public interface IResponse
	{
		/**
		 * Gets the steam that represents the response body.
		 * @return Not sure yet
		 * 
		 */		
		function getStream():*;
		
		/*
		/// <summary>
		/// Gets the steam that represents the response body.
		/// </summary>
		/// <returns></returns>
		[SuppressMessage("Microsoft.Design", "CA1024:UsePropertiesWhereAppropriate", Justification = "This could be expensive.")]
		Stream GetStream();
		*/
	}
}