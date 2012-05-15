import Fins;
import Fins.Model;

   inherit Model.DataObject;

   static void post_define(object context)
   {  
      belongs_to(context, "User", "author", "author_id");

  //    add_field(context, BinaryStringField("metadata", 1024, 0, "")); 
      add_field(context, MetaDataField("md", "metadata"));
      add_field(context, TransformField("nice_created", "created", format_created));
      add_field(context, TransformField("author_name", "md", get_name));
      add_field(context, TransformField("wiki_contents", "contents", context->app->render_wiki));
      add_field(context, TransformField("short_wiki_contents", "wiki_contents", make_excerpt));
   }

   static string get_name(object c, object i)
   {
     string un;
     if(un = c["name"]) return un;
     else return i["author"]["name"];
   }

   static string make_excerpt(string c, object i)
   {
     return FinScribe.Blog.make_excerpt(c, 140);
   }
   
   static string format_created(object c, object i)
   {
      string howlongago;

      c = c->distance(Calendar.now());

      if(c->number_of_minutes() < 3)
      {
         howlongago = "Just a moment ago";
      }
      else if(c->number_of_minutes() < 60)
      {
         howlongago = c->number_of_minutes() + " minutes ago";
      }
      else if(c->number_of_hours() < 24)
      {
         howlongago = c->number_of_hours() + " hours ago";
      }
      else
      {
         howlongago = c->number_of_days() + " days ago";
      }

      return howlongago;    
   }
   
   static object created()
   {
     return Calendar.Second();
   }
