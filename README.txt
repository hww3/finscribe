setting up FinBlog

0. Make sure that the FinBlog directory is within the Fins directory.
1. Create a mysql database for the blog.
     mysqladmin -uusername -p create blogDBName
2. Populate the new database with the config/schema.mysql script.
     mysql [connection parameters] blogDBName < config/schema.mysql
3. Edit the default theme contained in theme to your liking.
5. Create a configuration file for your blog, by copying config/dev.cfg 
     and editing as necessary, and save it in FinBlog/config.
6. Install the objects in the model:

     [from the Fins directory]
     ./fin_serve hilfe FinBlog yourconfigname

     when you get the > prompt, enter:

     application->install(); 

     answer the questions to set the password and email address
     for the administrator user.

     quit

     your application database will be populated with an initial user and 
     some starting content.

7. Start the blog application:

    ./fin_serve portnumber FinBlog yourconfigname

8. Access your application by pointing your browser to the proper 
  portnumber.
