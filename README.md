### About ###

This project demonstrates the integration of [PureMVC][], [Adobe Stratus][]
and [Django][] in a "chat" like AIR application. The project is of an
experimental/lab-like nature and it's encouraged to make or suggest
improvements to the code :)

   [PureMVC]: http://puremvc.org/
   [Adobe Stratus]: http://labs.adobe.com/technologies/stratus/
   [Django]: http://www.djangoproject.com/


### Instructions ###

This project does not include the files necessary to directly import it into
Flash Builder. In order to build PureStratus you need to create a new
project and manually copy all sourcefiles into the project folder.

1.  Create a new Flex Project, name it "PureStratus" and set the application
    type to "Desktop".

2.  Copy src/ and ext-src/ from this repository to your root project folder,
    overwriting existing files.

3.  Add ext-src/ to the build path of the project.

Additionally, a fair amount of configuration is done via compiler defines:

- CONFIG::LoggingEnabled
    - true or false. Enables logging via the Flex logging API.
    
            -define+=CONFIG::LoggingEnabled,true

- CONFIG::LogNotifications
    - true or false. Defines if PureMVC notifications should be logged.
    
            -define+=CONFIG::LogNotifications,false

- CONFIG::DjangoServerRootURI
    - URI of the peer exchange service.

            -define+=CONFIG::DjangoServerRootURI,"'http://127.0.0.1:8000'"

- CONFIG::StratusHost
    - Sets the URI for connecting to Adobe Stratus.

            -define+=CONFIG::StratusHost,"'rtmfp://stratus.adobe.com'"

- CONFIG::StratusKey
    - The developer key that should be used when connecting to
      Adobe Stratus.

            -define+=CONFIG::StratusKey,"'YOURKEYGOESHERE'"

- CONFIG::StratusMaxPeers
    - The maximum allowed peer connections.

            -define+=CONFIG::StratusMaxPeers,20

- CONFIG::StratusRepublishInterval
    - The interval (in ms) which the client republishes its near ID to the
      peer exchange service.

            -define+=CONFIG::StratusRepublishInterval,10000

      If you change this from 10 seconds remember to also change the
      MAXPEERAGE setting in djangopurestratus/settings.py.

To ease setup, copypaste the following to your "Additional compiler
arguments". Remember to replace with your Adobe Stratus developer key!

`-locale en_US -define+=CONFIG::LoggingEnabled,true -define+=CONFIG::DjangoServerRootURI,"'http://127.0.0.1:8000'" -define+=CONFIG::StratusHost,"'rtmfp://stratus.adobe.com'" -define+=CONFIG::StratusMaxPeers,20 -define+=CONFIG::StratusKey,"'YOURKEYGOESHERE'" -define+=CONFIG::StratusRepublishInterval,10000 -define+=CONFIG::LogNotifications,false`

This set of defines enables logging (except notifications) and also uses
localhost for the peer exchange service.

Logging is performed via the Flex logging API with targets for regular
trace() and also MonsterDebugger. The MonsterDebugger client has been
slightly modified to disable the FPS/Mem monitoring since monitoring more
than one client looks kind of funky.


### Django peer exchange service ###

You should only need a basic install of Django, no external applications
have been used. It is suggested to use the built-in development server
since logging in Django is currently done with print statements :)

1.  Set up the database

        ./manage.py syncdb --noinput
    
    The project includes some initial user data to get started quickly. Once
    synced, the database is prepopulated with four users: admin, u1, u2 and u3.
    The passwords these users are the same as their usernames. Admin, of course,
    has superuser priviliges.

2.  Start the development seerver

        ./manage.py runserver

    By default this starts the HTTP server on 127.0.0.1 port 8000.

The exchange application includes custom middleware which allows for
authentication over HTTP GET parameters or the X-Credentials HTTP header.

- Authenting an request as u1 using HTTP GET parameters

        http://127.0.0.1:8000/xchange/?username=u1&password=u1


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