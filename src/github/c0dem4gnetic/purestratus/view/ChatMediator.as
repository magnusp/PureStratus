package github.c0dem4gnetic.purestratus.view
{
	import mx.collections.ArrayCollection;
	
	import github.c0dem4gnetic.purestratus.controller.SyncCommand;
	import github.c0dem4gnetic.purestratus.model.PeerProxy;
	import github.c0dem4gnetic.purestratus.model.StratusProxy;
	import github.c0dem4gnetic.purestratus.model.UserMappingProxy;
	import github.c0dem4gnetic.purestratus.view.components.ChatComponent;
	
	import org.as3commons.logging.ILogger;
	import org.as3commons.logging.LoggerFactory;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class ChatMediator extends Mediator
	{
		private static const logger:ILogger = LoggerFactory.getClassLogger(ChatMediator);
		
		public static const NAME:String = 'MainMediator';

		[Bindable]
		private var peerCol:ArrayCollection = new ArrayCollection();

		public function ChatMediator(viewComponent:ChatComponent)
		{
			super(NAME, viewComponent);
		}
		
		override public function onRegister():void {
			chatComponent.addEventListener(ChatComponent.DISTRIBUTE, onDistribute);
			chatComponent.listPeers.dataProvider = peerCol;
		}
		
		private function onDistribute(event:Event):void {
			chatComponent.taMessages.text += "out> " + chatComponent.lastMessage + "\n";
			sendNotification(StratusProxy.DISTRIBUTE, chatComponent.lastMessage);
		}

		protected function get chatComponent():ChatComponent
		{
			return viewComponent as ChatComponent;
		}

		override public function listNotificationInterests():Array
		{
			return [SyncCommand.COMPLETE,
					PeerProxy.MESSAGE,
					UserMappingProxy.IDENTIFIED,
					PeerProxy.REMOVE]
		}
		
		override public function handleNotification(note:INotification):void
		{		
			var notificatonName:String = note.getName();
			var xhtml:Namespace = new Namespace("http://www.w3.org/1999/xhtml");
			switch(note.getName()) {
				case PeerProxy.MESSAGE:
					chatComponent.taMessages.text += "in> " + (note.getBody() as String) + "\n";
					break;
					
				case SyncCommand.COMPLETE:
					chatComponent.btnDistribute.enabled = true;
					chatComponent.tiMessage.enabled = true;
					break;
					
				case UserMappingProxy.IDENTIFIED:
					var peerElement:XML = note.getBody() as XML;
					xhtml = new Namespace("http://www.w3.org/1999/xhtml");
					peerCol.addItem({label:peerElement.xhtml::span.(@['class']=="username").toString(), peerElement:peerElement});
					break;
				
				case PeerProxy.REMOVE:
					var peerProxy:PeerProxy = note.getBody() as PeerProxy;
					xhtml = new Namespace("http://www.w3.org/1999/xhtml");
					peerCol.toArray().forEach(function(item:Object, index:int, array:Array):void {
						var nearID:String = item.peerElement.xhtml::span.(@['class'] == "nearID");
						if(nearID == peerProxy.peerID)
							peerCol.removeItemAt(index);
					});
					break;
			}
		}
	}
}