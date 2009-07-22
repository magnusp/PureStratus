package github.c0dem4gnetic.purestratus.model.vo
{
	import github.c0dem4gnetic.requestbuilder.ICredentials;

	public class DjangoUser implements ICredentials
	{
		public var authenticated:Boolean;
		private var _username:String;
		private var _password:String;
		
		public function DjangoUser() {
			
		}
		
		public function get password():String
		{
			return _password;
		}

		public function set password(v:String):void
		{
			_password = v;
		}

		public function get username():String
		{
			return _username;
		}

		public function set username(v:String):void
		{
			_username = v;
		}

	}
}