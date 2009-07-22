### About ###

This project demonstrates the integration of [PureMVC][], [Adobe Stratus][]
and [Django][] in a "chat" like application. The project is of an
experimental/lab-like nature and it's encouraged to make or suggest
improvements to the code :)

   [PureMVC]: http://puremvc.org/
   [Adobe Stratus]: http://labs.adobe.com/technologies/stratus/
   [Django]: http://www.djangoproject.com/

### Instructions ###

This project does not include the files necessary to directly import it into
Flash Builder. In order to build PureStratus you need to create a new
project and manually copy all sourcefiles into the project folder.

1. Create a new Flex Project, name it "PureStratus" and set the application
   type to "Desktop".
2. Copy src/ and ext-src/ from this repository to your root project folder,
   overwriting existing files.
3. Add ext-src/ to the build path of the project.

Additionally, a fair amount of configuration is done via compiler defines:

   - CONFIG::LoggingEnabled
      - true or false. Enables logging via the Flex logging API.
      - `-define+=CONFIG::LoggingEnabled,true`
   - CONFIG::LogNotifications
      - true or false. Defines if PureMVC notifications should be logged.
      - `-define+=CONFIG::logNotifications,false`
   - CONFIG::DjangoServerRootURI
      - URI of the peer exchange service
      - `-define+=CONFIG::DjangoServerRootURI,"'http://127.0.0.1:8000'"`
   - CONFIG::StratusHost
      - Sets the URI for connecting to Adobe Stratus
      - `-define+=CONFIG::StratusHost,"'rtmfp://stratus.adobe.com'"`
   - CONFIG::StratusKey
      - The developer key that should be used when connecting to Adobe Stratus
      - `-define+=CONFIG::StratusKey,"'YOURKEYGOESHERE'"`
   - CONFIG::StratusMaxPeers
      - The maximum allowed peer connections
      - `-define+=CONFIG::StratusMaxPeers,20`
   - CONFIG::StratusRepublishInterval
      - The interval (in ms) which the client republishes its near ID to the
        peer exchange service.
      - `-define+=CONFIG::StratusRepublishInterval,10000`

To ease setup, copypaste the following to your "Additional compiler
arguments", remember to replace with your Adobe Stratus developer key.

`-locale en_US -define+=CONFIG::LoggingEnabled,true -define+=CONFIG::DjangoServerRootURI,"'http://127.0.0.1:8000'" -define+=CONFIG::StratusHost,"'rtmfp://stratus.adobe.com'" -define+=CONFIG::StratusMaxPeers,20 -define+=CONFIG::StratusKey,"'YOURKEYGOESHERE'" -define+=CONFIG::StratusRepublishInterval,10000 -define+=CONFIG::LogNotifications,false`

This set of defines has logging enabled (except notifications) and also uses
localhost for the peer exchange service.

Logging is performed via the Flex logging API with targets for regular
trace() and also MonsterDebugger. The MonsterDebugger client has been
slightly modified to disable the FPS/Mem monitoring since monitoring more
than one client looks kind of funky.

### Django peer exchange service ###

If you're running against Python 2.6+ you only need a base install of
Django. If not, you also need to install [simplejson][].

To set up the database, do:

`./manage.py syncdb --noinput`

The project includes some initial user data to get started quickly. Once
synced, the database is prepopulated with four users: admin, u1, u2 and u3.
The passwords these users are the same as their usernames. Admin, of course,
has superuser priviliges.

To start the Django development server, do:

`./manage.py runserver`

This by default starts the server on 127.0.0.1 port 8000.

A custom middleware is provided that allows authentication over HTTP GET
parameters or the X-Credentials HTTP header.

`http://127.0.0.1:8000/xchange/?username=u1&password=u1`

This URL authenticates the request as u1.

   [simplejson]: http://www.undefined.org/python/

### Running the application ###

The application connects to the peer exchange service with credentials
provided in commandline arguments. This makes it slightly easier to test
with multiple users as you can have any number of run configurations in
Flash Builder with custom commandline arguments for the application.
Remember to set a unique publisher id for each run configuration in
Flash Builder!

`username=u1 password=u1`

This would connect to the peer exchange service with credentials for
the user u1.