package com.michas.async {
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import mx.rpc.AbstractOperation;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.soap.LoadEvent;
	import mx.rpc.soap.WebService;

	/// 
	/**
	 * Utility methods for creating tasks
	 * @author jmichas
	 * 
	 */	
	public class TaskInterop {
		/// 
		/// 
		/**
		 * Returns a Task<*> that completes immediately, but not synchronously.
		 * This is useful for running something after the current method, and its callers, finish.
		 * @param result
		 * @return 
		 * 
		 */		
		public static function defer(result : * = null):ITask {
			var r:TaskSource = new TaskSource();
			Util.defer(function():void { r.setResult(result); } );
			return r;
		}
		/// 
		/**
		 * Returns a Task<*> that completes with the given result after the given delay.
		 * @param delayMilliseconds
		 * @param result
		 * @return 
		 * 
		 */		
		public static function delay(delayMilliseconds : Number, result : * = null):ITask {
			var r:TaskSource = new TaskSource();
			Util.delay(delayMilliseconds, function():void { r.setResult(result); } );
			return r;
		}
		
		/// 
		/// 
		/// 
		/**
		 * A task that completes when the given object raises the given event.
		 * @param obj
		 * @param event The task's result is the event argument.
		 * @param ct If a cancel token is given and is cancelled before the event fires, the task cancels.
		 * @return 
		 * 
		 */		
		public static function listenForEvent(obj : Object, event : String, ct : ICancelToken = null) : ITask {
			var r : TaskSource = new TaskSource();
			obj.addEventListener(event, r.trySetResult);
			r.await(function():void { obj.removeEventListener(event, r.trySetResult); } );
			if (ct != null) ct.onCancelled(r.trySetCancelled);
			return r;
		}
		/// 
		/// 
		/// 
		/**
		 * A task that faults when the given object raises the given event.
		 * @param obj
		 * @param event The task's fault is the event argument.
		 * @param ct If a cancel token is given and is cancelled before the event fires, the task cancels.
		 * @return 
		 * 
		 */		
		public static function listenForErrorEvent(obj : Object, event : String, ct : ICancelToken = null) : ITask {
			var r : TaskSource = new TaskSource();
			obj.addEventListener(event, r.trySetFault);
			r.await(function():void { obj.removeEventListener(event, r.trySetFault); } );
			if (ct != null) ct.onCancelled(r.trySetCancelled);
			return r;
		}
		/// 
		/// 
		/// 
		/**
		 * A task that completes when the given object raises a given event matching the given condition.
		 * @param obj
		 * @param event The task's result is the matching event argument.
		 * @param condition
		 * @param ct If a cancel token is given and is cancelled before the event fires, the task cancels.
		 * @return 
		 * 
		 */		
		public static function listenForEventWhere(obj : Object, event : String, condition:Function, ct : ICancelToken = null) : ITask {
			if (condition == null) throw new ArgumentError("condition == null");
			if (condition.length != 1) throw new ArgumentError("condition.length != 1");
			var r : TaskSource = new TaskSource();
			var f:Function = function(e:*):void {
				if (condition(e)) {
					r.trySetResult(e);
				}
			};
			obj.addEventListener(event, f);
			r.await(function():void { obj.removeEventListener(event, f); } );
			if (ct != null) ct.onCancelled(r.trySetCancelled);
			return r;
		}
		/// 
		/// 
		/// 
		///
		/**
		 * A task that completes when the given object raises one of the given success or error events.
		 * The task completes if the success event happens first and faults if any of the error events happen first.
		 * The task's result is the event argument.
		 * @param obj
		 * @param successEvent
		 * @param errorEvents
		 * @param ct If a cancel token is given and is cancelled before any of the events fire, the task cancels.
		 * @return 
		 * 
		 */		
		public static function listenForEventOrErrorEvents(obj:Object, successEvent:String, errorEvents:*, ct : ICancelToken = null) : ITask {
			var cleanupToken : CancelTokenSource = new CancelTokenSource();
			
			var tasks:Vector.<ITask> = new Vector.<ITask>();
			tasks.push(listenForEvent(obj, successEvent, cleanupToken));
			for each (var ev : String in errorEvents)
				tasks.push(listenForErrorEvent(obj, ev, cleanupToken));
				
			var r:ITask = TaskEx.awaitAny(tasks);
			if (ct != null) ct.onCancelled(cleanupToken.cancel);
			r.await(cleanupToken.cancel);
			return r;
		}
		
		/// Returns a task that completes when the given clip enters the given frame.
		public static function listenForEnterFrame(clip:MovieClip, frame : int, ct : ICancelToken = null):ITask {
			return listenForEventWhere(clip, Event.ENTER_FRAME, function(e:*):Boolean { return clip.currentFrame == frame; }, ct);
		}
		/// Returns a task that completes when the given clip exits the given frame.
		public static function listenForExitFrame(clip:MovieClip, frame : int, ct : ICancelToken = null):ITask {
			return listenForEventWhere(clip, Event.EXIT_FRAME, function(e:*):Boolean { return clip.currentFrame == frame; }, ct);
		}
		/// Returns a task that completes when the given clip enters its ending frame.
		public static function listenForEnterEndFrame(clip:MovieClip, ct : ICancelToken = null):ITask {
			return listenForEnterFrame(clip, clip.totalFrames, ct);
		}
		/// Returns a task that completes when the given clip exits its ending frame.
		public static function listenForExitEndFrame(clip:MovieClip, ct : ICancelToken = null):ITask {
			return listenForExitFrame(clip, clip.totalFrames, ct);
		}
		
		/// 
		/// 
		/**
		 * Returns a Task<Loader> for a loader containing content pointed to by a URL.
		 * The task completes when the content has been loaded.
		 * @param url
		 * @param ct
		 * @return 
		 * 
		 */		
		public static function load(url:String, ct : ICancelToken = null):ITask {
			var loader: Loader = new Loader();
			var r:ITask = listenForEventOrErrorEvents(loader.contentLoaderInfo, Event.COMPLETE, new Array(IOErrorEvent.IO_ERROR, SecurityErrorEvent.SECURITY_ERROR), ct);
			loader.load(new URLRequest(url));
			if (ct != null) { ct.onCancelled(loader.close); }
			return r.continueWith(function():Loader { return loader; } );
		}
		/// 
		/// 
		/**
		 * Returns a Task<Loader> for a loader containing content serialized by a byte array.
		 * The task completes when the content has been loaded.
		 * @param data
		 * @param ct
		 * @return 
		 * 
		 */		
		public static function loadFromBytes(data:ByteArray, ct : ICancelToken = null):ITask {
			var loader: Loader = new Loader();
			var r:ITask = listenForEventOrErrorEvents(loader.contentLoaderInfo, Event.COMPLETE, new Array(IOErrorEvent.IO_ERROR, SecurityErrorEvent.SECURITY_ERROR), ct);
			loader.loadBytes(data);
			if (ct != null) { ct.onCancelled(loader.close); }
			return r.continueWith(function():Loader { return loader; } );
		}
		/// 
		/// 
		/**
		 * Returns a Task<String> containing the text pointed to by a URL.
		 * The task completes when the content has been loaded.
		 * @param url
		 * @param ct
		 * @return 
		 * 
		 */		
		public static function loadText(url:String, timeoutMilliseconds:Number = 0, headers:Dictionary = null, ct : ICancelToken = null):ITask {
			var loader: URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			var r:ITask = listenForEventOrErrorEvents(loader, Event.COMPLETE, new Array(IOErrorEvent.IO_ERROR, SecurityErrorEvent.SECURITY_ERROR), ct);
			var req:URLRequest = new URLRequest(url);
			req.idleTimeout = timeoutMilliseconds;
			for(var k:Object in headers){
				req.requestHeaders.push(new URLRequestHeader(String(k),headers[k]));
			}
			loader.load(req);
			if (ct != null) { ct.onCancelled(loader.close); }
			return r.continueWith(function():String { return loader.data; });
		}
		
		/// 
		/**
		 * Asynchronously connects to a web service, returning a Task<WebService>.
		 * @param url
		 * @return 
		 * 
		 */		
		public static function connectToSOAPWebService(url:String):ITask {
			var r:TaskSource = new TaskSource();
			var ws:WebService = new WebService();
			var fs:Function;
			var fe:Function;
			var cleanup:Function = function():void {
				ws.removeEventListener(LoadEvent.LOAD, fs);
				ws.removeEventListener(FaultEvent.FAULT, fe);				
			};
			fs = function(event:LoadEvent):void {
				cleanup();
				r.setResult(ws);
			};
			fe = function(fault:FaultEvent):void {
				cleanup();
				r.setFault(fault);
			};
			ws.addEventListener(LoadEvent.LOAD, fs);
			ws.addEventListener(FaultEvent.FAULT, fe);
			ws.loadWSDL(url);
			return r;
		}
		/// 
		/**
		 * Asynchronously invokes a web service's method, returning a Task<*> containing the eventual result.
		 * @param ws
		 * @param name
		 * @param args
		 * @return 
		 * 
		 */		
		public static function invokeWebServiceMethod(ws:WebService, name:String, ... args):ITask {
			var r:TaskSource = new TaskSource();
			var op:AbstractOperation = ws.getOperation(name);
			op.arguments = args;
			op.addEventListener(mx.rpc.events.FaultEvent.FAULT, function(e:Object):void { r.trySetFault(e.fault); } );
			op.addEventListener(mx.rpc.events.ResultEvent.RESULT, function(e:Object):void { r.trySetResult(e.result); } );
			op.send();
			return r;
		}
		
		/// 
		/**
		 * Starts playing the given sound, returning a Task<void> for when it completes.
		 * Playback can be stopped by canceling the given cancel token.
		 * @param sound
		 * @param ct
		 * @return 
		 * 
		 */		
		public static function playSound(sound : Sound, ct : ICancelToken = null) : ITask {
			var channel:SoundChannel = sound.play();
			var r:ITask = listenForEvent(channel, Event.SOUND_COMPLETE, ct);
			if (ct != null) { ct.onCancelled(channel.stop); }
			return r;
		}
		
		/// 
		/**
		 * Starts loading a sound from the given url, returning a Task<Sound> for when it completes or fails.
		 * Loading can be stopped by canceling the given cancel token.
		 * @param url
		 * @param ct
		 * @return 
		 * 
		 */		
		public static function loadSound(url : String, ct : ICancelToken = null) : ITask {
			var sound:Sound = new Sound();
			var r:ITask = listenForEventOrErrorEvents(sound, Event.COMPLETE, new Array(IOErrorEvent.IO_ERROR), ct).continueWith(function():Sound {
				return sound;
			});
			sound.load(new URLRequest(url));
			if (ct != null) { ct.onCancelled(sound.close); }
			return r;
		}
	}
}
