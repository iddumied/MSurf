My Changes on Surf
==================

History
~~~~~~~

* logs the every inputed and folowed url
* logs the date and time
* history file easy to use for scripting
* format: <date>::<url>


Bookmarks
~~~~~~~~~

* creates groubs by using dmenu
* bokkmark file easy to use for scripting
* format: <date>::<group>::url
* standart shortcut: MOD + B


Google Search
~~~~~~~~~~~~~

* works just like the url input
* standart shortcut: MOD + S


Faforited Sites
~~~~~~~~~~~~~~~

* shortcuts for faforited websites
* configurable in congif.h
* shortcut: MOD + 0..9



~~~~~~~~~~~~~
bjoern is the *fastest*, *smallest* and *most lightweight* WSGI server out there,
featuring

* ~ 1000 lines of C code
* Memory footprint ~ 600KB
* Single-threaded and without coroutines or other crap
* Full persistent connection ("*keep-alive*") support in both HTTP/1.0 and 1.1,
  including support for HTTP/1.1 chunked responses

Installation
~~~~~~~~~~~~
libev
-----
Arch Linux
   ``pacman -S libev``
Ubuntu
   ``apt-get install libev-dev``
Mac OS X (using homebrew_)
   ``brew install libev``
Your Contribution Here
   Fork me and send a pull request

bjoern
------
Make sure *libev* is installed and then::

   pip install bjoern

Usage
~~~~~
::

   bjoern.run(wsgi_application, host, port)

Alternatively, the mainloop can be run separately::

   bjoern.listen(wsgi_application, host, port)
   bjoern.run()

.. _WSGI:         http://www.python.org/dev/peps/pep-0333/
.. _libev:        http://software.schmorp.de/pkg/libev.html
.. _http_parser:  http://github.com/ry/http-parser
.. _homebrew: http://mxcl.github.com/homebrew/
