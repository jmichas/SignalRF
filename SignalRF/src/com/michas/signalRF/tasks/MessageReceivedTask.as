package com.michas.signalRF.tasks
{
	import com.michas.signalRF.IConnection;
	import com.michas.signalRF.events.SignalREvent;
	import com.michas.signalRF.events.SignalRReceivedEvent;
	
	import mx.utils.UIDUtil;
	import com.michas.signalRF.tasks.queue.AbstractQueueTask;

	public class MessageReceivedTask extends AbstractQueueTask
	{
		private var _callback:Function;
		private var _callbackData:Object;
		private var _connection:IConnection;
		
		public function MessageReceivedTask(connection:IConnection, callback:Function, callbackData:Object, type:String = "messageReceivedTask", priority:int=5, uid:Object=null, selfOverride:Boolean=false, blocking:Boolean=true)
		{
			_callback = callback;
			_callbackData = callbackData;
			_connection = connection;
			
			uid = UIDUtil.createUID();
			//trace("MessageTask UID", uid);
			super(type, priority, uid, selfOverride, blocking);
		}
		
		public override function start():void{
			//trace("MessageTask Start", uid);
			
			_connection.addEventListener(SignalREvent.RECEIVED, completeHandler);
			_callback(_callbackData);
			super.start();
		}
		
		private function completeHandler(event:SignalRReceivedEvent):void{
			_connection.removeEventListener(SignalREvent.RECEIVED, completeHandler);
			complete();
		}
		
		public override function complete():void{
			//trace("MessageTask Complete", uid);
			super.complete();
		}
	}
}