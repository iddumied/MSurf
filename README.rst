My Changes on Surf
==================



History
~~~~~~~

* logs every inputed and folowed url
* logs the date and time
* logs the Title and saves the icon of the page
* icons ar saved like: <page title>.ico
* history file easy to use for scripting
* format: <date>::<title>::<url>


Bookmarks
~~~~~~~~~

* creates groubs by using dmenu
* logs the title of the website
* bookmark file easy to use for scripting
* format: <date>::<group>::<title>::<url>
* standart shortcut: MOD + B


Google Search
~~~~~~~~~~~~~

* works just like the url input
* standart shortcut: MOD + S


Favourited Sites
~~~~~~~~~~~~~~~

* shortcuts for favourited websites
* configurable in congif.h
* shortcut: MOD + 0..9




surf - simple webkit-based browser
==================================
surf is a simple Web browser based on WebKit/GTK+.


Requirements
~~~~~~~~~~~~
In order to build surf you need GTK+ and Webkit/GTK+ header files.


Requirements
~~~~~~~~~~~~
In order to build surf you need GTK+ and Webkit/GTK+ header files.


Installation
~~~~~~~~~~~~
Edit config.mk to match your local setup (surf is installed into
the /usr/local namespace by default).

Afterwards enter the following command to build and install surf (if
necessary as root):

    make clean install


Running surf
~~~~~~~~~~~~
run
        surf [URL]
