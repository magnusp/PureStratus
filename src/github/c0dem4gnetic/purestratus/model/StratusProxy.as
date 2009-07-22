package github.c0dem4gnetic.purestratus.model
{
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.Timer;
	
	import org.as3commons.logging.ILogger;
	import org.as3commons.logging.LoggerFactory;
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class StratusProxy extends Proxy implements IProxy
	{
		private static const STREAMNAME:String = "RoarStream";
		private static const logger:ILogger = LoggerFactory.getClassLogger(StratusProxy);
		
		public static const NAME:String = "StratusProxy";
		
		private static const STRATUSHOST:String = CONFIG::StratusHost;
		private static const STRATUSKEY:String = CONFIG::StratusKey;
		
		//Notifications
		public static const STRATUSCONNECTED:String = NAME+"StratusConnected";
		public static const REPUBLISH:String = NAME + "Republish";
		public static const DISTRIBUTE:String = NAME + "Distribute";
		
		private var sendStream:NetStream;
		private var republishTimer:Timer;
				
		public function StratusProxy()
		{
			super(NAME, new NetConnection());
		}
		
		override public function onRegister():void {
			netConnection.maxPeerConnections = CONFIG::StratusMaxPeers;
			netConnection.addEventListener(NetStatusEvent.NET_STATUS, stratusConnectionHandler);
			netConnection.connect(STRATUSHOST + "/" + STRATUSKEY);
			republishTimer = new Timer(CONFIG::StratusRepublishInterval);
			republishTimer.addEventListener(TimerEvent.TIMER, onRepublishTimer);
			republishTimer.start();
		}
		
		public function get netConnection():NetConnection {
			return data as NetConnection;
		}
		
		private function onRepublishTimer(event:TimerEvent):void {
			try {
				var nearID:String = netConnection.nearID;
				sendNotification(StratusProxy.REPUBLISH, nearID);
			} catch (error:Error) {
				logger.warn("{0}\n{1}", error.message, error.getStackTrace());
			}
		}

		private function stratusConnectionHandler(event:NetStatusEvent):void {
			var statusCode:String = event.info.code;
			logger.debug("{0} {1}", netConnection.nearID.substr(0,5), statusCode);
			
			if(NetConnectionConstants.CONNECT_SUCCESS == statusCode) {
				sendNotification(StratusProxy.STRATUSCONNECTED, netConnection.nearID);
			} else if(NetStreamConstants.CONNECT_SUCCESS == statusCode) {
				var netStream:NetStream = event.info.stream as NetStream;
				var peerProxy:PeerProxy = new PeerProxy(netStream, "far-"+netStream.farID);
				peerProxy.isNear = false;
				facade.registerProxy(peerProxy);
				peerProxy.startStream();
			} else if(NetStreamConstants.CONNECT_CLOSED == statusCode) {
				facade.removeProxy("far-"+(event.info.stream as NetStream).farID);
			}
		}		
	}
}

internal final class NetConnectionConstants {
	internal static const CONNECT_SUCCESS:String = "NetConnection.Connect.Success";	
}

internal final class NetStreamConstants {
	internal static const CONNECT_SUCCESS:String="NetStream.Connect.Success";
	internal static const CONNECT_CLOSED:String="NetStream.Connect.Closed";	
}
