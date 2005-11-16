import Fins;
inherit Fins.FinsModel;
import Fins.Model;

static void create(Fins.Application a)
{
  ::create(a);
  load_model();
}

void load_model()
{
	
   object s = Sql.Sql(app()->config->get_value("model", "datasource"));
   object d = Fins.Model.DataModelContext(); 
   d->sql = s;
//   d->debug = 1;
   d->repository = this;
   add_object_type(Object_object(d));
   add_object_type(Object_version_object(d));
   add_object_type(Datatype_object(d));
   add_object_type(Comment_object(d));
   add_object_type(User_object(d));
}

class Object_object
{
   inherit Model.DataObject;

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
   inherit Model.DataObject;

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
   inherit Model.DataObject;

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
   inherit Model.DataObject;

   static void create(DataModelContext c)
   {  
      ::create(c);
      set_table_name("users");
      set_instance_name("user");
      add_field(PrimaryKeyField("id"));
      add_field(StringField("Name", 36, 0));
      add_field(StringField("UserName", 12, 0));
      add_field(StringField("Email", 64, 0));
      add_field(IntField("is_admin", 1, 1));
      add_field(IntField("is_active", 1, 1));
      add_field(StringField("Password", 16, 0));
      set_primary_key("id");
   }
}


class Comment_object
{
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
      add_field(TransformField("wiki_contents", "contents", app()->engine->render));
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


int new_from_string(string path, string contents, string type, int|void att, int|void skip_if_exists)
{
  int isnew = 1;
  object obj_o;
  array dtos = find("datatype", (["mimetype": type]));
               if(!sizeof(dtos))
               {
                  throw(Error.Generic("Mime type " + type + " not valid."));
               }
               else{
               object dto = dtos[0];
  mixed a;
  catch(a=find("object", (["path": path]) ));
  if(a && sizeof(a))
  {
    if(skip_if_exists) return 0;
    obj_o  = a[0];
    isnew=0;
  }
  else
               obj_o = new("object");
               obj_o["datatype"] = dto;
               if(att)
                 obj_o["is_attachment"] = 1;
               else 
                 obj_o["is_attachment"] = 0;
               obj_o["author"] = find_by_id("user", 1);
               obj_o["datatype"] = dto;
               obj_o["path"] = path;
           if(isnew)
            obj_o->save();

            object obj_n = new("object_version");
            obj_n["contents"] = contents;

            int v;
            object cv;

            obj_o->refresh();

            if(cv = obj_o["current_version"])
            {
              v = cv["version"];
            }
            obj_n["version"] = (v+1);
            obj_n["object"] = obj_o;
            obj_n["author"] = find_by_id("user", 1);
            obj_n->save();
            return 1;

            }
  
}
