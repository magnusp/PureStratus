package github.c0dem4gnetic.purestratus.controller
{
	import github.c0dem4gnetic.purestratus.model.DjangoProxy;
	import github.c0dem4gnetic.purestratus.model.StratusProxy;
	import github.c0dem4gnetic.purestratus.model.UserMappingProxy;
	import github.c0dem4gnetic.purestratus.view.ApplicationMediator;
	import github.c0dem4gnetic.purestratus.view.ChatMediator;
	
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class StartupCommand extends SimpleCommand implements ICommand
	{
		override public function execute(note:INotification):void
		{
			var app:PureStratus = note.getBody() as PureStratus;

			facade.registerCommand(SyncCommand.REGISTER, SyncCommand);
			facade.registerCommand(StratusProxy.STRATUSCONNECTED, StratusCommand);
			
			facade.registerProxy(new UserMappingProxy());
			facade.registerProxy(new DjangoProxy());	
			facade.registerProxy(new StratusProxy());
			
			facade.registerMediator(new ApplicationMediator(app));
			facade.registerMediator(new ChatMediator(app.chat));
			
		
		}
	}
}