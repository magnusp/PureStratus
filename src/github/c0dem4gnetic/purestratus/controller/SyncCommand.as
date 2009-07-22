package github.c0dem4gnetic.purestratus.controller
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.NetStream;
	import flash.net.URLLoader;
	
	import github.c0dem4gnetic.purestratus.model.DjangoProxy;
	import github.c0dem4gnetic.purestratus.model.PeerProxy;
	import github.c0dem4gnetic.purestratus.model.StratusProxy;
	import github.c0dem4gnetic.purestratus.model.UserMappingProxy;
	import github.c0dem4gnetic.requestbuilder.RequestBuilder;
	import github.c0dem4gnetic.requestbuilder.SimpleCredentials;
	
	import org.as3commons.logging.ILogger;
	import org.as3commons.logging.LoggerFactory;
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	/*	SyncCommand manages the initial communication with the
	 *	peer exchange service. This includes registering the
	 *	near (local) peer id and retrieving a list of potential
	 *	remote peers (those that have registered within a
	 *	certain span of time.
	*/
	public class SyncCommand extends SimpleCommand implements ICommand
	{
		private static const logger:ILogger = LoggerFactory.getClassLogger(SyncCommand);
		public static const REGISTER:String = "SyncCommandRegister";
		public static const COMPLETE:String = "SyncCommandComplete";
		
		override public function execute(notification:INotification):void {
			switch(notification.getName()) {
				case SyncCommand.REGISTER:
					djangoProxy.loginCredentials = new SimpleCredentials(PureStratus.ARGS['username'], PureStratus.ARGS['password']);
					djangoProxy.authenticate();
					new RequestBuilder().post(djangoProxy.uri+"/exchange/register/")
										.header(djangoProxy.credentialsHeader)
										.variable("nearid", notification.getBody() as String)
										.on(Event.COMPLETE, onRegisterComplete)
										.on(IOErrorEvent.IO_ERROR, ioErrorHandler)
										.compile().call();
					break;
				default:
					logger.warn("Unhandled notification: {0}", notification.getName());
			}
		}
		
		private function get stratusProxy():StratusProxy {
			return facade.retrieveProxy(StratusProxy.NAME) as StratusProxy;	
		}

		private function get djangoProxy():DjangoProxy {
			return facade.retrieveProxy(DjangoProxy.NAME) as DjangoProxy;
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void {
			var urlLoader:URLLoader = event.target as URLLoader;
			urlLoader.removeEventListener(Event.COMPLETE, onRegisterComplete);
			urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			logger.fatal(event.text);
		}
		
		private function onRegisterComplete(event:Event):void {
			var urlLoader:URLLoader = event.target as URLLoader;
			urlLoader.removeEventListener(Event.COMPLETE, onRegisterComplete);
			urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			
			var doc:XML = new XML(urlLoader.data);
			
			var xhtml:Namespace = new Namespace("http://www.w3.org/1999/xhtml");
			var peerElements:* = doc..xhtml::ul.(@id=="peerlist").xhtml::li;
			var userMappingProxy:UserMappingProxy = facade.retrieveProxy(UserMappingProxy.NAME) as UserMappingProxy;
			for each(var peerElement:* in peerElements) {
				
				var username:String = peerElement.xhtml::span.(@['class']=="username");
				var peerID:String = peerElement.xhtml::span.(@['class']=="nearID");
				var last_assigned:String = peerElement.xhtml::span.(@['class']=="last_assigned");
				userMappingProxy.add(peerID, peerElement);
				
				var netStream:NetStream = new NetStream(stratusProxy.netConnection, peerID); 
				var peerProxy:PeerProxy = new PeerProxy(netStream, "far-"+peerID);
				peerProxy.isNear = false;
				facade.registerProxy(peerProxy);
				peerProxy.startStream();
			}
			sendNotification(SyncCommand.COMPLETE);
		}
	}
}