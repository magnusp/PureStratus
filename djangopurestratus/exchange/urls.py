from django.conf.urls.defaults import *

urlpatterns = patterns('djangopurestratus.exchange.views',
    (r'^$', 'index'),
    (r'^register/$', 'register'),
    (r'^identify/$', 'identify'),    
)

