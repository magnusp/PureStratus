package github.c0dem4gnetic.purestratus.model
{
	import de.polygonal.ds.HashMap;
	
	import flash.events.Event;
	import flash.net.URLLoader;
	
	import github.c0dem4gnetic.requestbuilder.RequestBuilder;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class UserMappingProxy extends Proxy implements IProxy
	{
		public static const NAME:String = "UserMappingProxy";
		public static const IDENTIFIED:String = NAME+"Identified";
		
		public function UserMappingProxy() {
			super(UserMappingProxy.NAME, new HashMap());
		}
		
		public function get hashMap():HashMap {
			return data as HashMap;
		}
		
		public function add(peerID:String, value:XML):void {
			hashMap.insert(peerID, value);
		}
		
		private function onIdentifyPeerComplete(event:Event):void {
			var urlLoader:URLLoader = event.target as URLLoader;
			urlLoader.removeEventListener(Event.COMPLETE, onIdentifyPeerComplete);
			
			var doc:XML = new XML(urlLoader.data);
			var xhtml:Namespace = new Namespace("http://www.w3.org/1999/xhtml");
			var peerElement:XML = new XML(doc..xhtml::ul.(@id=="peer").xhtml::li.toXMLString());
			
			add(peerElement.xhtml::span.(@['class']=="nearID").toString(), peerElement);
			
			sendNotification(UserMappingProxy.IDENTIFIED, peerElement);
		}
		
		public function identifyPeerID(peerID:String):void {
			if(hashMap.find(peerID)) {
				sendNotification(UserMappingProxy.IDENTIFIED, hashMap.find(peerID));
			} else {
				var djangoProxy:DjangoProxy = facade.retrieveProxy(DjangoProxy.NAME) as DjangoProxy;
				new RequestBuilder().get(djangoProxy.uri+"/exchange/identify/")
									.header(djangoProxy.credentialsHeader)
									.variable("farid", peerID)
									.on(Event.COMPLETE, onIdentifyPeerComplete)
									.compile().call();
			}
		}
	}
}