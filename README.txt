setting up FinBlog

FinBlog supports storing its data either using mySQL or SQLite. Depending 
on which you choose to use, you'll need to have the appropriate libraries 
installed before building and installing Pike. If you already have Pike 
installed, and later choose to add support for one of these database 
engines, you can easily do that. SQLite is probably the easier of the two 
to install support for, as you can use Monger.

0. Make sure that the FinBlog directory is within the Fins directory.
1. Prepare the database:
   Mysql:
   a. Create a mysql database for the blog.
     maysqladmin [connection parameters] create mydbname
   b. Populate the new database with the config/schema.mysql script.
     mysql [connection parameters] mydbname < config/schema.mysql

   SQLite:
   a. Create and populate the database:
     sqlite dbfilename < config/schema.sqlite

3. Create a configuration file for your blog, by copying config/dev.cfg 
     and editing as necessary.
4. Install the objects in the model:

     [from the Fins directory]
     ./fin_serve hilfe FinBlog yourconfigname

     when you get the > prompt, enter:

     application->install(); 
     quit

     answer the questions when prompted.

     your application database will be populated with an initial user and 
     some starting content.

7. Start the blog application:

    ./fin_serve portnumber FinBlog yourconfigname

8. Access your application by pointing your browser to the proper 
  portnumber.
