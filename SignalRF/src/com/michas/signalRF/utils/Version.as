package com.michas.signalRF.utils
{
	public class Version
	{
		private var _build:int = -1;
		private var _revision:int = -1;
		private var _major:int;
		private var _minor:int;
		
		public function Version(major:int,minor:int,revision:int = -1, build:int = -1)
		{
			_major = major;
			_minor = minor;
			_revision = revision;
			_build = build;
		}
		
		public function toString():String{
			var v:String = _major.toString() + "." + _minor;
			v += _revision!=-1 ? "." + _revision : "";
			v += _build!=-1 ? "." + _build : "";
			
			return v;
		}
	}
}