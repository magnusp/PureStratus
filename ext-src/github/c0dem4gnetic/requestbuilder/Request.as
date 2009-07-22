package github.c0dem4gnetic.requestbuilder
{
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class Request
	{
		internal var urlRequest:URLRequest;
		internal var urlLoader:URLLoader;
		
		public function Request()
		{
		}
		
		public function call():void {
			//urlRequest.authenticate = false;
			urlLoader.load(urlRequest);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
		}
		
		private function onIOError(event:IOErrorEvent):void {
			event.target.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			trace(event.text);
		}
	}
}