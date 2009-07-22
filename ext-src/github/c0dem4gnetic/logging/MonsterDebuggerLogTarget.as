package github.c0dem4gnetic.logging
{
	import mx.logging.ILogger;
	import mx.logging.LogEvent;
	import mx.logging.targets.LineFormattedTarget;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import org.as3commons.logging.LogLevel;

	public class MonsterDebuggerLogTarget extends LineFormattedTarget
	{
        public static const COLOR_DEBUG:uint = MonsterDebugger.COLOR_NORMAL;
        public static const COLOR_INFO:uint = 0x0000FF;
        public static const COLOR_WARN:uint = MonsterDebugger.COLOR_WARNING;
        public static const COLOR_ERROR:uint = MonsterDebugger.COLOR_ERROR;
        public static const COLOR_FATAL:uint = 0xFF3300;
        
        public static var colorDebug:uint = COLOR_DEBUG;
        public static var colorInfo:uint = COLOR_INFO;
        public static var colorWarn:uint = COLOR_WARN;
        public static var colorError:uint = COLOR_ERROR;
        public static var colorFatal:uint = COLOR_FATAL;

		public function MonsterDebuggerLogTarget()
		{
			super();
		}
		
		override public function logEvent(event:LogEvent):void {
			var logger:ILogger = event.target as ILogger;
			var logColor:uint;
			switch(event.level) {
				case LogLevel.DEBUG:
					logColor = colorDebug;
					break;
					
				case LogLevel.ERROR:
					logColor = colorError;
					break;
					
				case LogLevel.FATAL:
					logColor = colorFatal;
					break;
					
				case LogLevel.INFO:
					logColor = colorInfo;
					break;
					
				case LogLevel.NONE:
					logColor = colorInfo;
					break;
					
				case LogLevel.WARN:
					logColor = colorWarn;
					break;
					
				default:
					logColor = colorInfo;					
			}
			
			var level:String = "";
	        if (includeLevel)
	        {
	            level = "[" + LogEvent.getLevelString(event.level) +
	                    "]" + fieldSeparator;
	        }
			MonsterDebugger.trace(logger.category, level + event.message, logColor);
		}
	}
}