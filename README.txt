Setting up FinScribe

FinScribe runs under Pike versions 7.8 or newer. Additionally, there 
are a number of additional modules which provide necessary functionality. 
Item 0 below describes these prerequisites.

FinScribe supports storing its data either using mySQL, PostgreSQL or 
SQLite. Depending on which you choose to use, you'll need to have the 
appropriate libraries installed before building and installing Pike. If 
you already have Pike installed, and later choose to add support for one 
of these database engines, you can easily do that. SQLite is probably the 
easier of the three to install support for, as you can use Monger.

0. Make sure you have installed any prerequisite software:
   a. Third party libraries:
      - A supported database engine client (mysql or SQLite)
      - PCRE
      - libxml2 (optional but recommended, required for RSS/ATOM support)
      - libfcgi (optional, only required if using FinsRunner to serve
        your application using FastCGI
   b. Modules bundled with Pike (only necessary if you installed the 
      corresponding library _after_ you compiled/installed Pike.)
      - _Regexp_PCRE
      - Mysql (if using Mysql as your database)
      - Postgresql module (if using Postgres as your database)
   c. Third party Pike modules, installable using the following command: 
         pike -x monger modulename
      - Sql.Provider.SQLite (if using SQLite as your database)
      - Public.Parser.XML2 (optional, required for RSS/ATOM support)
      - Public.Web.FCGI (if deploying using FastCGI)
      - Public.Web.Wiki (v1.5 or newer) 
      - Public.Tools.ConfigFiles (any pubic version will do) 
           [included with distributions of FinScribe]
      - Public.Syndication (any public version will do, optional) 
           [included with distributions of FinScribe]

1. Prepare the database:
   Mysql:
   a. Create a mysql database for the blog.
     mysqladmin [connection parameters] create mydbname

   SQLite:
   a. No action required, though the location where your database file 
      will reside must be writable by the FinScribe user.

   PostgreSQL:
   a. Create database for the blog:
     createdb mydbname

2. Start the blog application:

    cd FinScribe
    bin/start.sh -p portnumber --config yourconfigname

   where yourconfigname is the name of a configuration file, which is 
   normally located in the config directory. Release packages of FinScribe 
   typically have a pre-bundled configuration called "dev", which is the
   default configuration name, so you don't have to provide it. Either way,
   you should review the contents of this file to make sure the settings
   are correct.

3. Access your application by pointing your browser to the proper 
   port number supplied when you start fin serve. On first access, you'll
   be presented with the installation wizard. Simply follow the steps
   to install and configure your FinScribe instance.

WHAT TO DO WHEN THINGS GO WRONG

Chances are, you'll run into difficulties getting things set up. We're 
working on making the experience easier, but the problems aren't all 
completely solved. Drop the author a line, and he will be more than happy 
to walk you through solving all of the problems.

FULL TEXT

FinScribe includes a plugin for using the Fins/Xapian Full Text 
application. When the fulltext plugin is enabled and configured, content 
will be indexed and be available for search.

The Fins/Xapian Full Text application may be downloaded from the following 
location:

http://hg.welliver.org/fulltext

When configured and running, you should create a new index for FinScribe to
store its information in. Also, you should use the grant_access tool in 
order to get an authorization code. Once you have this information, you
can enable the full text plugin in the FinScribe administration interface.

The 3 settings you'll need to provide are:

Index server url: normally http://localhost:8124, but may be different 
based on your installtion

Index name: this is the name of the full text index you've created using
the Fins/Xapian administrative tools.

Index Authorization: this is the authorization code that will allow 
FinScribe to search and update the full text index. You can get an
authorization code for your particular index by using the Fins/Xapian 
administrative tools.


THEMES

As of release 0.5, FinScribe is completely Themeable. In addition to the 
default (ugly and boring) theme, we've got a few, much nicer themes that 
we've ported from other applications such as WordPress. We'll make them 
available here, so that you can make your FinScribe installation a little 
prettier.

The easiest way to manage your themes is using the admin interface. This 
will allow you to upload new or updated themes as well as set the active 
theme. The admin interface also allows you to download a copy of the theme 
so that you can make modifications more easily.

Also, it's worth noting that you can customize the sidebar that's 
included with FinScribe, and used by all of the themes. The sidebar's 
content is stored in a document called theme/default/portlet-1, 
and you can access it by going to your site's index page. It will be 
listed under "P" for "portlet-1. 

* Old theme management technique

The following material describes the use of themes without using the admin 
interface. Normally it won't be necessary, but it's included here for 
completeness.

To install a new theme, simply download the theme file and unzip it into 
your FinScribe/themes directory. Once you've done that, you'll need to 
set the site.theme preference to the name of the theme you'd like to use. 
To do that, do the following:

bin/start.sh  --hilfe --config yourconfigname

at the prompt, run the following command:

  application->get_sys_pref("site.theme")["value"] = "yournewthemename";
  quit

And that's it! To switch back to the default theme, simply follow the 
above commands, and use the theme name "default".
