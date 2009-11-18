import Fins;
import Fins.Model;

   inherit Model.DataObject;

   static void post_define()
   {  
  //    add_field(BinaryStringField("metadata", 1024, 0, "")); 
      add_field(MetaDataField("md", "metadata"));
      add_field(TransformField("nice_created", "created", format_created));
      add_field(TransformField("wiki_contents", "contents", context->app->render_wiki));
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
