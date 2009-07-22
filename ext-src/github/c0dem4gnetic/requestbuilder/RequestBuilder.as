package github.c0dem4gnetic.requestbuilder
{
	import com.adobe.serialization.json.JSON;
	
	import de.polygonal.ds.LinkedQueue;
	
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;

	public class RequestBuilder
	{
		private var _url:String;
		private var method:String;
		private var handlers:LinkedQueue;
		private var variables:URLVariables;
		private var _data:String;
		private var acceptHeader:URLRequestHeader;
		private var requestHeaders:Array;
		private var _carry:Object;
		private var isFollowRedirect:Boolean = true;
		
		public function RequestBuilder()
		{
		}
		
		public function url(url:String):RequestBuilder {
			this._url = url;
			
			return this;
		}
		
		public function post(url:String):RequestBuilder {
			this._url = url;
			this.method = URLRequestMethod.POST;
			
			return this;
		}

		public function get(url:String):RequestBuilder {
			this._url = url;
			this.method = URLRequestMethod.GET;
			
			return this;
		}
		
		public function put(url:String):RequestBuilder {
			this._url = url;
			this.method = "put";
			
			return this;
		}
		
		/**
		 * Attaches an eventlistener to the internal URLLoader:
		 * Does not bubble
		 * Has priority 0
		 * Is not weak referenced
		 * 
		 * @param eventType
		 * @param eventHandler
		 * @return The current RequestBuilder
		 * 
		 */		
		public function on(eventType:String, eventHandler:Function):RequestBuilder {
			if(handlers==null)
				handlers=new LinkedQueue();
			
			handlers.enqueue({"eventType":eventType, "eventHandler":eventHandler});
			return this;
		}
		
		public function variable(key:String, value:Object):RequestBuilder {
			if(variables==null) {
				variables = new URLVariables();
			}
			variables[key] = value;
			
			return this;
		}
		
		public function accept(value:String):RequestBuilder {
			if(acceptHeader==null) {
				acceptHeader = new URLRequestHeader();
			}
			acceptHeader.name = "Accept";
			acceptHeader.value = value;
						
			return this;
		}
		
		public function header(nameOrURLRequestHeader:*, valueOrNull:String=null):RequestBuilder {
			if(requestHeaders==null)
				requestHeaders = new Array();

			if(nameOrURLRequestHeader is URLRequestHeader) {
				requestHeaders.push(nameOrURLRequestHeader)
			} else {
				if(valueOrNull==null)
					throw new Error("valueOrNull cannot be null when specifing a header name");
				requestHeaders.push(new URLRequestHeader(nameOrURLRequestHeader, valueOrNull));
			}
			
			return this;
		}
		
		public function followRedirect(value:Boolean):RequestBuilder {
			this.isFollowRedirect = value;
			
			return this;
		}
		
		public function data(value:String):RequestBuilder {
			this._data = value;
			return this;
		}
		
		public function json(object:*):RequestBuilder {
			this._data = JSON.encode(object);
			return this;
		}
		
		public function carry(value:Object):RequestBuilder {
			this._carry = value;
			
			return this;
		}
				
		public function compile():Request {
			var urlLoader:URLLoader;
			if(_carry!=null) {
				urlLoader = new CarryURLLoader(_carry);
			} else {
				urlLoader = new URLLoader();
			}
			
			var urlRequest:URLRequest = new URLRequest(_url);

			urlRequest.method = method;
			if(handlers!=null) {
				while(handlers.isEmpty() != true) {
					var handlerObject:Object = handlers.dequeue();
					urlLoader.addEventListener(handlerObject.eventType, handlerObject.eventHandler, false, 0, false);
				}
			}
			
			if(acceptHeader!=null) {
				urlRequest.requestHeaders.push(acceptHeader);
			}
			
			if(requestHeaders!=null) {
				for each(var requestHeader:URLRequestHeader in requestHeaders) {
					urlRequest.requestHeaders.push(requestHeader);
				}
			}
			
			if(_data!=null) {
				urlRequest.data = _data;
			} else if(variables != null) {
				urlRequest.data = variables;
			}
			
			urlRequest.followRedirects = isFollowRedirect;
			
			var request:Request = new Request();
			request.urlRequest = urlRequest;
			request.urlLoader = urlLoader;			
			return request;
		}
	}
}
