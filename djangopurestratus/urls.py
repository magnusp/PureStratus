from django.conf.urls.defaults import *
from django.contrib import admin

admin.autodiscover()
admin.site.root_path = '/admin/'

urlpatterns = patterns('',
    (r'^admin/', include(admin.site.urls)),
    (r'^accounts/', include('djangopurestratus.registration.urls')),
    (r'accounts/profile/$', 'djangopurestratus.exchange.views.profile'),
    (r'^exchange/', include('djangopurestratus.exchange.urls')),
)
