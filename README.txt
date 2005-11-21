setting up FinBlog

0. Make sure that the FinBlog directory is within the Fins directory.
1. Create a mysql database for the blog.
     maysqladmin [connection parameters] create mydbname
2. Populate the new database with the config/schema.mysql script.
     mysql [connection parameters] mydbname < config/schema.mysql
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
