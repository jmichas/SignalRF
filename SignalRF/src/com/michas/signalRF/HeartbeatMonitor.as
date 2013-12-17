package com.michas.signalRF
{

	import com.michas.signalRF.enums.ConnectionState;
	import com.michas.signalRF.interfaces.IDisposable;
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;


	public class HeartbeatMonitor implements IDisposable
	{
		private var _hasBeenWarned:Boolean;
		public function get hasBeenWarned():Boolean { return _hasBeenWarned; }
		public function set hasBeenWarned(value:Boolean):void
		{
			if (_hasBeenWarned == value)
				return;
			_hasBeenWarned = value;
		}
		
		private var _timedOut:Boolean;
		public function get timedOut():Boolean { return _timedOut; }
		public function set timedOut(value:Boolean):void
		{
			if (_timedOut == value)
				return;
			_timedOut = value;
		}
		
		private var _isDisposed:Boolean;
		public function get isDisposed():Boolean { return _isDisposed; }
		
		
		private var _connection:IConnection;
		private var _beatInterval:Number;
		private var _beatId:uint;
		private var _timer:Timer;
		private var _monitorKeepAlive:Boolean;
		
		public function HeartbeatMonitor(connection:IConnection, beatInterval:Number)
		{
			_isDisposed = false;
			_connection = connection;
			_beatInterval = beatInterval;
		}
		
		public function start():void{
			_isDisposed = false;
			_connection.markLastMessage();
			_connection.markActive();
			_monitorKeepAlive = _connection.keepAliveData != null && _connection.transport.supportsKeepAlive;
			
			hasBeenWarned = false;
			timedOut = false;
			
			_timer = new Timer(_beatInterval);
			_timer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void{
				beat();
			});
			_timer.start();
		}
		
		public function stop():void{
			if(_timer!=null && _timer.running){
				_timer.stop();
				_timer = null;
			}
		}
		
		public function beat():void{
			var timeElapsed:Number = new Date().getTime() - _connection.lastMessageAt;
			//_connection.log("Beat at {0}", new Date().getTime());
			if (_monitorKeepAlive) {
				checkKeepAlive(timeElapsed);
			}
			
			// Ensure that we successfully marked active before continuing the heartbeat.
			_connection.markActive()
		}
		
		private function checkKeepAlive(timeElapsed:Number):void {
			var keepAliveData:KeepAliveData = _connection.keepAliveData;
			
			// Only check if we're connected
			if (_connection.state == ConnectionState.CONNECTED) {
				//_connection.log("lastMessageAt {0} {1}", _connection.dateFormatter.format(new Date(_connection.lastMessageAt)), _connection.lastMessageAt);
				//_connection.log("Elapsed Time {0}, timeout {1}, timeoutWarning {2}",Math.round(timeElapsed/1000), keepAliveData.timeout/1000, keepAliveData.timeoutWarning/1000);
				// Check if the keep alive has completely timed out
				if (timeElapsed >= keepAliveData.timeout) {
					if(!_timedOut){
						_connection.log("Keep alive timed out.  Notifying transport that connection has been lost.");
						_timedOut = true;
						// Notify transport that the connection has been lost
						_connection.transport.lostConnection(_connection);
					}
				} else if (timeElapsed >= keepAliveData.timeoutWarning) {
					// This is to assure that the user only gets a single warning
					if (!_hasBeenWarned) {
						_connection.log("Keep alive has been missed, connection may be dead/slow.");
						
						_hasBeenWarned = true;
						_connection.onConnectionSlow();
					}
				} else {
					_hasBeenWarned = false;
					_timedOut = false;
				}
			}
		}
		
		public function dispose():void{
			stop();
			_isDisposed = true;
		}
	}
}