package github.c0dem4gnetic.requestbuilder
{
	public class SimpleCredentials implements ICredentials
	{
		protected var _username:String;
		protected var _password:String;
		
		public function SimpleCredentials(username:String=null, password:String=null)
		{
			this._username = username;
			this._password = password;
		}
		
		public function get username():String {
			return _username;
		}

		public function get password():String {
			return _password;
		}
	}
}