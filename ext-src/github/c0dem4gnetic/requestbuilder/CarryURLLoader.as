package github.c0dem4gnetic.requestbuilder
{
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	/**
	 * URLLoader that has an additional property "carry" to transport
	 * some value after the request finishes
	 * 
	 * @author magnus
	 * 
	 */	
	public class CarryURLLoader extends URLLoader
	{
		public var carry:Object;
		
		public function CarryURLLoader(carry:*=null, request:URLRequest=null)
		{
			super(request);
			this.carry = carry;
		}		
	}
}