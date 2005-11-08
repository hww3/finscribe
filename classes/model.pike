import Fins;
import Fins.Model;
inherit Fins.FinsModel;

static void create()
{
  load_model();
}

void load_model()
{
	
   object s = Sql.Sql(application->config->get_value("model", "datasource"));
   object d = Fins.Model.DataModelContext(); 
   d->sql = s;
   d->debug = 1;
   add_object_type(Object_object(d));
   add_object_type(Object_version_object(d));
   add_object_type(Datatype_object(d));
   add_object_type(Comment_object(d));
   add_object_type(User_object(d));
}

class Object_object
{
   inherit DataObject;

   static void create(DataModelContext c)
   {  
      ::create(c);
      set_table_name("objects");
      set_instance_name("object");
      add_field(PrimaryKeyField("id"));
      add_field(KeyReference("author", "author_id", "user"));
      add_field(KeyReference("datatype", "datatype_id", "datatype"));
      add_field(StringField("path", 128, 0));
      add_field(IntField("is_attachment", 0, 0));
      add_field(DateTimeField("created", 0, created));
      add_field(TransformField("title", "path", lambda(mixed n){return (n/"/")[-1];}));
      add_field(TransformField("nice_created", "created", format_created));
      add_field(InverseForeignKeyReference("versions", "object_version", "object", Model.Criteria("ORDER BY version DESC")));
      add_field(InverseForeignKeyReference("current_version", "object_version", "object", Model.Criteria("ORDER BY version DESC LIMIT 1"), 1));
      add_field(InverseForeignKeyReference("comments", "comment", "object"));
      set_primary_key("id");
   }

   static object created()
   {
     return Calendar.Second();
   }

   string format_created(object c)
   {
     return c->format_ext_ymd();
   }
}

class Object_version_object
{
   inherit DataObject;

   static void create(DataModelContext c)
   {  
      ::create(c);
      set_table_name("object_versions");
      set_instance_name("object_version");
      add_field(PrimaryKeyField("id"));
      add_field(KeyReference("object", "object_id", "object"));
      add_field(KeyReference("author", "author_id", "user"));
      add_field(IntField("version", 0, 1));
      add_field(StringField("subject", 128, 1));
      add_field(TransformField("content_length", "contents", lambda(mixed n){return sizeof(n);}));
      add_field(StringField("contents", 102400, 0));
      add_field(DateTimeField("created", 0, created));
      add_field(InverseForeignKeyReference("comments", "comment", "object"));

      set_primary_key("id");
   }

   static object created()
   {
     return Calendar.Second();
   }
}

class Datatype_object
{
   inherit DataObject;

   static void create(DataModelContext c)
   {  
      ::create(c);
      set_table_name("datatypes");
      set_instance_name("datatype");
      add_field(PrimaryKeyField("id"));
      add_field(StringField("mimetype", 32, 0));
      set_primary_key("id");
   }

   static object created()
   {
     return Calendar.Second();
   }
}


class User_object
{
   inherit DataObject;

   static void create(DataModelContext c)
   {  
      ::create(c);
      set_table_name("users");
      set_instance_name("user");
      add_field(PrimaryKeyField("id"));
      add_field(StringField("Name", 36, 0));
      add_field(StringField("UserName", 12, 0));
      add_field(StringField("Email", 64, 0));
      add_field(StringField("Password", 16, 0));
      set_primary_key("id");
   }
}


class Comment_object
{
   inherit DataObject;

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
      add_field(TransformField("wiki_contents", "contents", application->engine->render));
      set_primary_key("id");
   }
   
   static string format_created(object c)
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
}
