package com.michas.signalRF.utils
{
	public class Resources
	{
		
		public static const	nojQuery:String = "jQuery was not found. Please ensure jQuery is referenced before the SignalR client JavaScript file.";
		public static const	noTransportOnInit:String = "No transport could be initialized successfully. Try specifying a different transport or none at all for auto initialization.";
		public static const	errorOnNegotiate:String = "Error during negotiation request.";
		public static const	stoppedWhileLoading:String = "The connection was stopped during page load.";
		public static const	stoppedWhileNegotiating:String = "The connection was stopped during the negotiate request.";
		public static const	errorParsingNegotiateResponse:String = "Error parsing negotiate response.";
		public static const	protocolIncompatible:String = "You are using a version of the client that isn't compatible with the server. Client version {0}, server version {1}.";
		public static const	sendFailed:String = "Send failed.";
		public static const	parseFailed:String = "Failed at parsing response:String = {0}";
		public static const	longPollFailed:String = "Long polling request failed.";
		public static const	eventSourceFailedToConnect:String = "EventSource failed to connect.";
		public static const	eventSourceError:String = "Error raised by EventSource";
		public static const	webSocketClosed:String = "WebSocket closed.";
		public static const	pingServerFailedInvalidResponse:String = "Invalid ping response when pinging server:String = '{0}'.";
		public static const	pingServerFailed:String = "Failed to ping server.";
		public static const	pingServerFailedStatusCode:String = "Failed to ping server.  Server responded with status code {0}, stopping the connection.";
		public static const	pingServerFailedParse:String = "Failed to parse ping server response, stopping the connection.";
		public static const	noConnectionTransport:String = "Connection is in an invalid state, there is no transport active.";
		
		public static const error_UrlCantContainQueryStringDirectly:String = "Url cannot contain query string directly. Pass query string values in using available overload.";
		public static const error_ProxiesCannotBeAddedConnectionStarted:String = "A HubProxy cannot be added after the connection has been started.";
		public static const message_Reconnecting:String = "Connection started reconnecting before invocation result was received.";
		public static const message_ConnectionClosed:String = "Connection was disconnected before invocation result was received.";
		
		public function Resources()
		{
		}
	}
}