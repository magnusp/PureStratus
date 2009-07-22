import datetime

from django.http import HttpResponse, HttpResponseRedirect, HttpResponseServerError
from django.shortcuts import render_to_response
from django.conf import settings
from django.contrib.auth.models import User

from djangopurestratus.exchange.models import Peer
from djangopurestratus.exchange.middleware import must_be_authenticated

@must_be_authenticated
def index(request):
    import datetime as dt
    def peerAgeExclusionFilter(qs):
        return qs.exclude(last_assigned__lt=dt.datetime.now() - settings.MAXPEERAGE)
    
    PeerQS = Peer.objects.all()
    
    currentUserPeer = PeerQS.get(user=request.authenticated_as)
    #restPeers = peerAgeExclusionFilter(PeerQS.exclude(user=request.authenticated_as))

    restPeers = Peer.objects.exclude(last_assigned__lt=dt.datetime.now() - settings.MAXPEERAGE) \
                            .exclude(user=request.authenticated_as)
    return render_to_response("exchange/peering/peerlist.xhtml", {"currentUserPeer":currentUserPeer,
                                                                 "restPeers":restPeers})

@must_be_authenticated
def identify(request):
    print "Identify request from %s" % request.authenticated_as.username
    peer = None
    if "username" in request.GET:
        user = User.objects.get(username=request.GET['username'])
        peer = Peer.objects.get(user=user)
    elif "farid" in request.GET:
        peer = Peer.objects.get(nearID=request.GET['farid'])

    return render_to_response("exchange/peering/identify.xhtml", {"peer":peer})

@must_be_authenticated
def register(request):
    if "nearid" in request.POST:
        peer = Peer.objects.get_or_create(user=request.authenticated_as)[0]
        peer.nearID = request.POST['nearid']
        peer.save()
        print "Registered nearID for %s" % request.authenticated_as.username
    return HttpResponseRedirect("/exchange/")

def profile(request):
    return HttpResponse("Profile should be here", mimetype="text/plain")
