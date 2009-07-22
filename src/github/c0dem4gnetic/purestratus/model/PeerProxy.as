package github.c0dem4gnetic.purestratus.model
{
	import flash.events.NetStatusEvent;
	import flash.net.NetStream;
	
	import org.as3commons.logging.ILogger;
	import org.as3commons.logging.LoggerFactory;
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;
	
	public class PeerProxy extends Proxy implements IProxy
	{
		private static const logger:ILogger = LoggerFactory.getClassLogger(PeerProxy);
		
		public static const NAME:String = "PeerProxy";
		public static const MESSAGE:String = NAME+"Message";
		public static const REGISTERED:String = NAME+"Registered";
		public static const CONNECT:String = NAME+"Connect";
		public static const REMOVE:String = NAME+"Remove";
		
		public static const TYPE_NEAR:String = NAME+"TypeNear";
		public static const TYPE_FAR:String = NAME+"TypeFar";
		
		private var _isNear:Boolean=true;
		private var _streamName:String = "DefaultStratusStream";
		private var delayedConnects:Array = new Array();
		
		public function PeerProxy(netStream:NetStream, proxyName:String=NAME)
		{
			super(proxyName, netStream);
		}
		
		public function get netStream():NetStream {
			return data as NetStream;
		}
		
		private function set streamName(value:String):void {
			_streamName = value;
		}
		
		public function set isNear(value:Boolean):void {
			this._isNear = value;
		}
		
		public function get isNear():Boolean {
			return this._isNear;
		}
		
		public function get peerID():String {
			if(isNear) {
				var stratusProxy:StratusProxy = facade.retrieveProxy(StratusProxy.NAME) as StratusProxy;
				return stratusProxy.netConnection.nearID;
			}
			return netStream.farID;
		}
		
		private function get stratusProxy():StratusProxy {
			return facade.retrieveProxy(StratusProxy.NAME) as StratusProxy;
		}
		
		override public function onRegister():void {
			var netStreamClient:Object = new Object();
			if(_isNear) {
				netStream.addEventListener(NetStatusEvent.NET_STATUS, netStreamHandler);
				netStreamClient.onPeerConnect = function(subscriberStream:NetStream):Boolean {
					sendNotification(PeerProxy.CONNECT, subscriberStream.farID);
					return true;
				}
				netStream.client = netStreamClient;
				sendNotification(PeerProxy.REGISTERED, this, PeerProxy.TYPE_NEAR);
			} else {
				netStreamClient.onMessage = function(o:*):void {
					sendNotification(PeerProxy.MESSAGE, o);
				}
				netStream.client = netStreamClient;
				sendNotification(PeerProxy.REGISTERED, this, PeerProxy.TYPE_FAR);
			}
			
		}
		
		override public function onRemove():void {
			logger.info("Removing proxy {0}", getProxyName());
			netStream.removeEventListener(NetStatusEvent.NET_STATUS, netStreamHandler);
			sendNotification(PeerProxy.REMOVE, this, isNear ? TYPE_NEAR : TYPE_FAR);
		}
		
		private function netStreamHandler(event:NetStatusEvent):void {
			var stratusProxy:StratusProxy = facade.retrieveProxy(StratusProxy.NAME) as StratusProxy;
			logger.debug("{0} netStreamHandler {1}", stratusProxy.netConnection.nearID.substr(0,5), event.info.code);
		}
		
		public function startStream():void {
			if(_isNear) {
				logger.debug("Starting to publish on: {0}", _streamName);
				netStream.publish(_streamName);
			} else {
				logger.debug("Starting playback of remote stream: '{0}'", _streamName);
				netStream.play(_streamName);
			}
		}
		
		public function distribute(message:String):void {
			if(!_isNear) {
				throw new Error("Recieving streams cannot distribute messages");
			}
			logger.debug("Distributing: {0}", message);
			netStream.send("onMessage", message);
		}
	}
}