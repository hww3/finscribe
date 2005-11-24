import Fins;
inherit Fins.FinsModel;
import Fins.Model;

static void create(Fins.Application a)
{
  ::create(a);
  load_model();
}

public void load_model()
{
	
   object s = Sql.Sql(app()->config->get_value("model", "datasource"));
   object d = Fins.Model.DataModelContext(); 
   d->sql = s;
   d->debug = 1;
   d->repository = this;
   add_object_type(Object_object(d));
   add_object_type(Object_version_object(d));
   add_object_type(Datatype_object(d));
	add_object_type(Category_object(d));
   add_object_type(Comment_object(d));
   add_object_type(User_object(d));
}

Model.DataObjectInstance find_by_id(string|object ot, int id)
{
   object o;
   string key = "";

   if(objectp(ot))
     key = sprintf("OBJECTCACHE_%s_%d", ot->instance_name, id);
   else key=sprintf("OBJECTCACHE_%s_%d", ot, id);

   o = cache()->get(key);

   if(o) return o;

   o = ::find_by_id(ot, id);
   if(o) cache()->set(key, o, 600);

   return o;
}

mixed get_datatypes()
{
  mixed res;

  res = cache()->get("DATATYPES_");
  
  if(res) return res;

  res = find("datatype", ([]));

  cache()->set("DATATYPES_", res, 600);

  return res;
}

mixed get_metadata(object obj)
{
  string md = obj["metadata"];
  if(strlen(md))  
    return decode_value(md);
  else return ([]);
}

void set_metadata(object obj, mixed metadata)
{
  obj["metadata"] = encode_value(metadata);
}

mixed get_categories()
{
  mixed res;

  res = cache()->get("CATEGORIES_");
  
  if(res) return res;

  res = find("category", ([]));

  cache()->set("CATEGORIES_", res, 600);

  return res;
}

public array get_blog_entries(object obj, int|void max)
{
  array o = find("object", ([ "is_attachment": 2, "parent": obj]), 
                        Model.Criteria("ORDER BY path DESC" + (max?(" LIMIT " + max) : "")));

  return o;
}

public string get_object_name(string obj)
{
   return (obj/"/")[-1];
}

public object get_fbobject(array args, Request|void id)
{
   array r;
   string a = args*"/";

   r=cache()->get("PATHOBJECTCACHE_" + a);

   if(r && sizeof(r)) return r[0];

   r = find("object", (["path": a]));

   if(sizeof(r))
   {
     cache()->set("PATHOBJECTCACHE_" + a, r, 600);
     return r[0];
   }
   else return 0;
}

public string get_object_title(object obj, Request|void id)
{
   string t = obj["current_version"]["subject"];
   return (t && sizeof(t))?t:get_object_name(obj["path"]);
}

public string get_object_contents(object obj, Request|void id)
{

   return obj["current_version"]["contents"];
}

public string get_when(object c)
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



/*

    here are the model objects for the o-r mapping
  
*/


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
      add_field(KeyReference("parent", "parent_id", "object", UNDEFINED, 1));
      add_field(StringField("path", 128, 0));
      add_field(IntField("is_attachment", 0, 0));
      add_field(DateTimeField("created", 0, created));
      add_field(TransformField("title", "path", get_title));
      add_field(TransformField("nice_created", "created", format_created));
      add_field(CacheField("current_version", "current_version_uncached", c));
      add_field(StringField("metadata", 1024, 0, ""));
      add_field(InverseForeignKeyReference("current_version_uncached", "object_version", "object", Model.Criteria("ORDER BY version DESC LIMIT 1"), 1));
      add_field(InverseForeignKeyReference("comments", "comment", "object"));
      add_field(MultiKeyReference(this, "categories", "objects_categories", "object_id", "category_id", "category", "id"));
      set_primary_key("id");
   }

   static object created()
   {
     return Calendar.Second();
   }

   string get_title(mixed n, object i)
   {
     string a = i["current_version"]["subject"];
     if(a && sizeof(a)) return a;
     else return (n/"/")[-1];
   }


   string format_created(object c, object i)
   {
     return c->format_ext_ymd();
   }
}

class Category_object
{
	inherit Model.DataObject;
	
	static void create(DataModelContext c)
	{
		::create(c);
		set_table_name("categories");
		set_instance_name("category");
		add_field(PrimaryKeyField("id"));
		add_field(StringField("category", 64, 0));
		add_field(MultiKeyReference(this, "objects", "objects_categories", "category_id", "object_id", "object", "id"));
		set_primary_key("id");
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
      add_field(TransformField("content_length", "contents", lambda(mixed n, object i){return sizeof(n);}));
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
               obj_o["author"] = find("user", (["UserName": "admin"]))[0];
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
            obj_n["author"] = find("user", (["UserName": "admin"]))[0];
            obj_n->save();
            return 1;

            }
  
}
