import Fins;
import Fins.Model;

   inherit Model.DataObject;

   static void create(DataModelContext c)
   {  
      ::create(c);
      set_table_name("comments");
      set_instance_name("comment");
      add_field(PrimaryKeyField("id"));
      add_field(KeyReference("object", "object_id", "object"));
      add_field(KeyReference("author", "author_id", "user"));
      add_field(StringField("contents", 1024, 0));
      add_field(DateTimeField("created", 0, created));
      add_field(TransformField("nice_created", "created", format_created));
      add_field(TransformField("wiki_contents", "contents", c->app->engine->render));
      set_primary_key("id");
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
