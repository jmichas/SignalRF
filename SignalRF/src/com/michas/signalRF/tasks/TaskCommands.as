package com.michas.signalRF.tasks
{
	
	import com.adobe.utils.StringUtil;
	import com.michas.async.ICancelToken;
	import com.michas.async.ITask;
	import com.michas.async.TaskInterop;
	import com.michas.async.TaskSource;
	import com.worlize.websocket.WebSocket;
	import com.worlize.websocket.WebSocketErrorEvent;
	import com.worlize.websocket.WebSocketEvent;
	import com.worlize.websocket.WebSocketMessage;
	
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.system.Capabilities;
	import flash.utils.Dictionary;
	
	import mx.utils.StringUtil;

	
	public class TaskCommands extends TaskInterop
	{
		public function TaskCommands()
		{
			super();
		}
		public static function get empty():ITask{
			return new EmptyTask();
		}
		
		public static function connectWebSocket(socket:WebSocket):ITask{
			var r:TaskSource = new TaskSource();
			socket.addEventListener(WebSocketErrorEvent.CONNECTION_FAIL, function(e:Object):void { r.trySetFault(e.text); } );
			socket.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void { r.trySetFault(e.text); } );
			socket.addEventListener(WebSocketEvent.OPEN, function(e:Object):void { r.trySetResult(e.message); } );
			socket.connect();
			return r;
		}
		public static function closeWebSocket(socket:WebSocket):ITask{
			var r:TaskSource = new TaskSource();
			socket.addEventListener(WebSocketEvent.CLOSED, function(e:Object):void { r.trySetResult(e.message); } );
			socket.close();
			return r;
		}

		public static function sendDataToWebSocket(socket:WebSocket, data:String):ITask{
			var dataObj:Object = JSON.parse(data);
			var r:TaskSource = new TaskSource();
			socket.sendUTF(data);
			return r;
		}
		
		public static function postDataToUrl(url:String, data:URLVariables, appVersion:String, headers:Dictionary = null,  ct:ICancelToken = null):ITask{
			var r:TaskSource = new TaskSource();
			var request:URLRequest = new URLRequest(url);
			request.data = data;
			request.method = URLRequestMethod.POST;
			request.userAgent = mx.utils.StringUtil.substitute("{0}/{1} ({2})","SignalR.Client.Flex",appVersion, Capabilities.os);
			if(headers!=null){
				for(var k:Object in headers){
					request.requestHeaders.push(new URLRequestHeader(String(k),headers[k]));
				}
			}
			var loader:URLLoader = new URLLoader();
			//listenForEventOrErrorEvents(loader, Event.COMPLETE, new Array(IOErrorEvent.IO_ERROR, SecurityErrorEvent.SECURITY_ERROR), ct);
			/*loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, function(e:HTTPStatusEvent):void{
				trace(e);
			});
			loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, function(e:HTTPStatusEvent):void{
				trace(e);
			});*/
			loader.addEventListener(Event.COMPLETE, function(e:Event):void{
				r.trySetResult(loader.data);
			});
			request.manageCookies = false;
			loader.load(request);
			if (ct != null) { ct.onCancelled(loader.close); }
			return r;
			/*return r.continueWith(
				function(result:*):void {
					trace(result)
					return loader.data; 
				});*/
		}
	}
	
}
