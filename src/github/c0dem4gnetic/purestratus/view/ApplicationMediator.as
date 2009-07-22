package github.c0dem4gnetic.purestratus.view
{
	import github.c0dem4gnetic.purestratus.controller.SyncCommand;
	import github.c0dem4gnetic.purestratus.model.PeerProxy;
	import github.c0dem4gnetic.purestratus.model.StratusProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class ApplicationMediator extends Mediator
	{
		public static const NAME:String = 'ApplicationMediator';
		
		public function ApplicationMediator(viewComponent:PureStratus)
		{
			super(NAME, viewComponent);
		}
		
		override public function listNotificationInterests():Array
		{
			return [StratusProxy.STRATUSCONNECTED,
					SyncCommand.REGISTER,
					SyncCommand.COMPLETE,
					PeerProxy.CONNECT,
					PeerProxy.REMOVE];
		}
		
		override public function handleNotification(note:INotification):void
		{
			switch(note.getName()) {
				case StratusProxy.STRATUSCONNECTED:
					pureStratus.setStatus("Connected to Adobe Stratus");
					break;
					
				case SyncCommand.REGISTER:
					pureStratus.setStatus("Registering nearID with peer exchange service");
					break;
				
				case SyncCommand.COMPLETE:
					pureStratus.setStatus("Registered with peer exchange service");
					break;
					
				case PeerProxy.CONNECT:
					var farID:String = note.getBody() as String;
					pureStratus.setStatus("Remote peer connected, " + farID.substr(0,5) + "...");
					break;
					
				case PeerProxy.REMOVE:
					if(note.getType() == PeerProxy.TYPE_FAR) {
						var peerProxy:PeerProxy = note.getBody() as PeerProxy;
						pureStratus.setStatus("Remote peer disconnect, " + peerProxy.peerID.substr(0,5) + "...");						
					}
					break;
			}
		}
		
		protected function get pureStratus():PureStratus
		{
			return viewComponent as PureStratus;
		}
	}
}