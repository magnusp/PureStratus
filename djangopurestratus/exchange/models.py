from django.db import models
from django.contrib.auth.models import User

class Peer(models.Model):
    nearID = models.TextField(blank=False)
    last_assigned = models.DateTimeField(auto_now=True)
    user = models.OneToOneField(User)
    
    def __unicode__(self):
        return 'user %s id %s' % (self.user.username, self.nearID)