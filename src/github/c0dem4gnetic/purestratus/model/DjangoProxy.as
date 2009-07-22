package github.c0dem4gnetic.purestratus.model
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequestHeader;
	
	import github.c0dem4gnetic.purestratus.model.vo.DjangoUser;
	import github.c0dem4gnetic.requestbuilder.SimpleCredentials;
	
	import org.as3commons.logging.ILogger;
	import org.as3commons.logging.LoggerFactory;
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class DjangoProxy extends Proxy implements IProxy
	{
		private static const logger:ILogger = LoggerFactory.getClassLogger(DjangoProxy);
		
		public static const NAME:String = "DjangoProxy";
		public static const AUTHENTICATED:String = NAME + "Authenticated";
		public static const AUTHENTICATION_ERROR:String = NAME + "AuthenticationError";
		
		
		public function DjangoProxy()
		{
			super(NAME, new DjangoUser());
		}
				
		public function get djangoUser():DjangoUser {
			return data as DjangoUser;
		}
		
		public function get uri():String {
			return CONFIG::DjangoServerRootURI;
		}
		
		public function get credentialsHeader():URLRequestHeader {
			return new URLRequestHeader("X-Credentials", djangoUser.username+";"+djangoUser.password);
		}
		
		public function set loginCredentials(credentials:SimpleCredentials):void {
			djangoUser.username = credentials.username;
			djangoUser.password = credentials.password;
			logger.info("Credentials set: {0};{1}", djangoUser.username, djangoUser.password);
		}
		
		public function authenticate():void {
			djangoUser.authenticated = true;
			logger.debug("Authenticate as {0}", djangoUser.username);
			sendNotification(DjangoProxy.AUTHENTICATED);
		}
	}
}