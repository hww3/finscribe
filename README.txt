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
   b. Populate the new database with the config/schema.mysql script.
     mysql [connection parameters] mydbname < config/schema.mysql

   SQLite:
   a. Create and populate the database:
     sqlite dbfilename < config/schema.sqlite

   PostgreSQL:
   a. Create database for the blog:
     createdb mydbname
   b. Populate the new database with the config/schema.postgres script.
     psql [connection parameters] mydbname < config/schema.postgres

3. Create a configuration file for your blog in the config/ direcotry, by 
     copying config/dev.cfg and editing as necessary.

    cp config/dev.cfg.sample config/myconfigname.cfg

4. Install the objects in the model:

     [from the Fins directory]
     ./fin_serve.pike hilfe FinScribe yourconfigname

     when you get the > prompt, enter:

     application->install(); 
     quit

     answer the questions when prompted.

     your application database will be populated with an initial user and 
     some starting content.

7. Start the blog application:

    ./fin_serve.pike [-p portnumber] . yourconfigname

8. Access your application by pointing your browser to the proper 
  portnumber.
