Setting up FinScribe

FinScribe runs under Pike versions 7.6.50 or newer. Additionally, there 
are a number of additional modules which provided necessary functionality. 
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
      - libxml2
      - libfcgi (optional, only required if using FinsRunner to serve
        your application using FastCGI
   b. Modules bundled with Pike (only necessary if you installed the 
      corresponding library _after_ you compiled/installed Pike.)
      - _Regexp_PCRE
      - Mysql
      - Postgresql module
   c. Third party Pike modules, installable using the following command: 
         pike -x monger modulename
      - Sql.Provider.SQLite (if using SQLite as your database)
      - Public.Parser.XML2
      - Public.Web.RSS
      - Public.Web.Wiki
      - Public.Tools.ConfigFiles
      - Public.Web.FCGI (if deploying using FastCGI)

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

    ./fin_serve.pike -p portnumber . yourconfigname

3. Access your application by pointing your browser to the proper 
   port number supplied when you start fin serve. On first access, you'll
   be presented with the installation wizard. Simply follow the steps
   to install and configure your FinScribe instance.
