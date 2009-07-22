from django.conf import settings
from django.contrib.auth.models import User
from django.contrib.auth import authenticate
from django.http import HttpResponseServerError

class AuthenticatingMiddleware(object):
    def process_request(self, request):
        if 'HTTP_X_CREDENTIALS' in request.META:
            username, password = request.META['HTTP_X_CREDENTIALS'].rsplit(";", 1)
            user = authenticate(username=username, password=password)
            if not user:
                return HttpResponseServerError("Not authorized")
            request.authenticated_as = user
        elif 'username' in request.GET and 'password' in request.GET:
            user = authenticate(username=request.GET['username'], password=request.GET['password'])
            if not user:
                return HttpResponseServerError("Not authorized")
            request.authenticated_as = user
            
def must_be_authenticated(f):
    def wrap(request, *args, **kwargs):
        if hasattr(request, "authenticated_as"):
            return f(request, *args, **kwargs)
        return HttpResponseServerError("Error, authenticate thru X-Credentials header")
        
    wrap.__doc__=f.__doc__
    wrap.__name__=f.__name__
    return wrap