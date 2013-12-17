package com.michas.signalRF
{
	import com.michas.signalRF.utils.ICredentials;
	
	public class Credentials implements ICredentials
	{
		public function Credentials(username:String, password:String)
		{
			_username = username;
			_password = password;
		}
		
		private var _username:String;
		private var _password:String;
		
		public function get username():String
		{
			return _username;
		}
		
		public function set username(u:String):void
		{
			_username = u;
		}
		
		public function get password():String
		{
			return _password;
		}
		
		public function set password(p:String):void
		{
			_password = p;
		}
	}
}