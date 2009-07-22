package github.c0dem4gnetic.purestratus
{
	import mx.logging.Log;
	import mx.logging.targets.LineFormattedTarget;
	import mx.logging.targets.TraceTarget;
	
	import github.c0dem4gnetic.logging.MonsterDebuggerLogTarget;
	import github.c0dem4gnetic.purestratus.controller.StartupCommand;
	import github.c0dem4gnetic.purestratus.model.StratusProxy;
	
	import org.as3commons.logging.ILogger;
	import org.as3commons.logging.LoggerFactory;
	import org.as3commons.logging.impl.FlexLoggerFactory;
	import org.puremvc.as3.multicore.interfaces.IFacade;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.facade.Facade;

	public class ApplicationFacade extends Facade implements IFacade
	{
		private static const logger:ILogger = LoggerFactory.getClassLogger(ApplicationFacade);;
		
		// Notification constants 
		public static const STARTUP:String = 'startup';
		
		public function ApplicationFacade( key:String )
		{
			super(key);
			if(!CONFIG::LoggingEnabled) {
				LoggerFactory.loggerFactory = null;
			} else {
				var logTarget:LineFormattedTarget = new MonsterDebuggerLogTarget();
				logTarget.includeLevel = true;
				Log.addTarget(logTarget);
				logTarget = new TraceTarget();
				Log.addTarget(logTarget);
				LoggerFactory.loggerFactory = new FlexLoggerFactory();
			}
		}

		/**
         * Singleton ApplicationFacade Factory Method
         */
        public static function getInstance( key:String ) : ApplicationFacade 
        {
            if (instanceMap[key] == null )
            	instanceMap[key] = new ApplicationFacade(key);
            return instanceMap[key] as ApplicationFacade;
        }
        
	    /**
         * Register Commands with the Controller 
         */
        override protected function initializeController( ) : void 
        {
            super.initializeController();            
            registerCommand(ApplicationFacade.STARTUP, StartupCommand);            
        }
        
        private function get ignoredNotifications():Array {
        	return [StratusProxy.REPUBLISH];
        }
        
        override public function notifyObservers ( notification:INotification ):void {
			CONFIG::LogNotifications {
				if(ignoredNotifications.every(function(item:String, index:int, array:Array):Boolean {
					return item!=notification.getName() ? true : false;  
				})) {
					logger.info("notifyObservers - {0}", notification.getName());
				}
			}
			
			super.notifyObservers(notification);
		}
		
        /**
         * Application startup
         * 
         * @param app a reference to the application component 
         */  
        public function startup( app:PureStratus ):void
        {
        	sendNotification( STARTUP, app );
        }
	}
}