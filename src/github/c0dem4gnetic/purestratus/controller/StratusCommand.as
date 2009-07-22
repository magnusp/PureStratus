package github.c0dem4gnetic.purestratus.controller
{
	import flash.events.HTTPStatusEvent;
	import flash.net.NetStream;
	
	import github.c0dem4gnetic.purestratus.model.DjangoProxy;
	import github.c0dem4gnetic.purestratus.model.PeerProxy;
	import github.c0dem4gnetic.purestratus.model.StratusProxy;
	import github.c0dem4gnetic.purestratus.model.UserMappingProxy;
	import github.c0dem4gnetic.requestbuilder.RequestBuilder;
	
	import org.as3commons.logging.ILogger;
	import org.as3commons.logging.LoggerFactory;
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class StratusCommand extends SimpleCommand implements ICommand
	{
		private static const logger:ILogger = LoggerFactory.getClassLogger(StratusCommand);
		
		override public function execute(notification:INotification):void {
			var peerProxy:PeerProxy;
			
			switch(notification.getName()) {
				case StratusProxy.STRATUSCONNECTED:
					facade.removeCommand(StratusProxy.STRATUSCONNECTED);
					facade.registerCommand(StratusProxy.DISTRIBUTE, StratusCommand);
					facade.registerCommand(StratusProxy.REPUBLISH, StratusCommand);
					facade.registerCommand(PeerProxy.REGISTERED, StratusCommand);
					facade.registerCommand(PeerProxy.CONNECT, StratusCommand);
					var netStream:NetStream = new NetStream(stratusProxy.netConnection, NetStream.DIRECT_CONNECTIONS);
					var nearPeerProxy:PeerProxy = new PeerProxy(netStream);
					facade.registerProxy(nearPeerProxy);
					nearPeerProxy.startStream();
					
					// All done with the near side, register with the
					// peer exchange service and connect to far peers.
					sendNotification(SyncCommand.REGISTER, stratusProxy.netConnection.nearID);
					break;
					
				case PeerProxy.REGISTERED:
					peerProxy = notification.getBody() as PeerProxy;
					logger.info("PeerProxy registered, near? {0}", peerProxy.isNear);
					break;
					
				case StratusProxy.REPUBLISH:
					if(djangoProxy.djangoUser.authenticated) {
						new RequestBuilder().post(djangoProxy.uri+"/exchange/register/")
											.followRedirect(false)
											.header(djangoProxy.credentialsHeader)
											.variable("nearid", notification.getBody() as String)
											.on(HTTPStatusEvent.HTTP_RESPONSE_STATUS, responseSink)
											.compile().call();
					} else {
						logger.fatal("Django user wasnt authenticated");
					}
					break;
					
				case StratusProxy.DISTRIBUTE:
					peerProxy = facade.retrieveProxy(PeerProxy.NAME) as PeerProxy;
					peerProxy.distribute(notification.getBody() as String);
					break;
					
				case PeerProxy.CONNECT:
					var farID:String = notification.getBody() as String;
					peerProxy = facade.retrieveProxy("far-"+farID) as PeerProxy;
					logger.info("{0} connected to {1}", peerProxy.peerID.substr(0, 5),
														 stratusProxy.netConnection.nearID.substr(0, 5));
					var userMappingProxy:UserMappingProxy = facade.retrieveProxy(UserMappingProxy.NAME) as UserMappingProxy;
					userMappingProxy.identifyPeerID(peerProxy.peerID);
					break;
					
				default:
					logger.warn("Unhandled notification: {0}", notification.getName());
					break;
			}
		}
		
		private function get djangoProxy():DjangoProxy {
			return facade.retrieveProxy(DjangoProxy.NAME) as DjangoProxy;
		}
		
		private function get stratusProxy():StratusProxy {
			return facade.retrieveProxy(StratusProxy.NAME) as StratusProxy;	
		}
		
		// Do-nothing event handler, avoids "errors" being traced
		private function responseSink(event:HTTPStatusEvent):void {
			event.target.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, responseSink);
		}
	}
}