import Fins;
import Fins.Model;
inherit Fins.FinsModel;

//object datatype_instance_module = FinScribe.Objects;
//object datatype_definition_module = FinScribe.Model;

//object repository = FinScribe.Repo;

function find = Fins.Model.old_find;

public void load_model()
{
  if(!config["app"] || !config["app"]["installed"]) 
  {
    werror("Not starting model.\n");
    return;
  }
  else
  {
    werror("Starting model.\n");
  }

  ::load_model();

}

/*
void register_types()
{

   repository->add_object_type(FinScribe.Model.Object(context), FinScribe.Objects.Object);
   repository->add_object_type(FinScribe.Model.Object_version(context), FinScribe.Objects.Object_version);
   repository->add_object_type(FinScribe.Model.Datatype(context), FinScribe.Objects.Datatype);   
   repository->add_object_type(FinScribe.Model.Category(context), FinScribe.Objects.Category);
   repository->add_object_type(FinScribe.Model.Comment(context), FinScribe.Objects.Comment);
   repository->add_object_type(FinScribe.Model.User(context), FinScribe.Objects.User);
   repository->add_object_type(FinScribe.Model.Group(context), FinScribe.Objects.Group);
   repository->add_object_type(FinScribe.Model.ACL(context), FinScribe.Objects.ACL);
   repository->add_object_type(FinScribe.Model.ACLRule(context), FinScribe.Objects.ACLRule);
   repository->add_object_type(FinScribe.Model.Preference(context), FinScribe.Objects.Preference);
   repository->add_object_type(FinScribe.Model.Whee(context), FinScribe.Objects.Whee);
}
*/

//!
Model.DataObjectInstance find_nearest_parent(string path)
{
  array a = path/"/";

  for(int i = sizeof(a); i != 0; i--)
  {
    string p = (a[0..(i-1)] * "/");
    mixed o = Fins.Model.find.objects((["path": p]));
    if(sizeof(o)) return o[0];
  }

  return 0;
}

string get_object_name(string n)
{
  return (n/"/")[-1];
}

mixed get_datatypes()
	{
  mixed res;

  res = cache->get("DATATYPES_");
  
  if(res) return res;

  res = Fins.Model.find.datatypes_all();

  cache->set("DATATYPES_", res, 600);

  return res;
}

mixed get_metadata(object obj)
{
  string md = obj["metadata"];
  if(md && strlen(md))  
    return decode_value(md);
  else return ([]);
}

void set_metadata(object obj, mixed metadata)
{  obj["metadata"] = encode_value(metadata);
}

mixed get_categories()
{
  mixed res;

  res = cache->get("CATEGORIES_");
  
  if(res) return res;

  res = Fins.Model.find.categories_all();

  cache->set("CATEGORIES_", res, 600);

  return res;
}

void clear_categories()
{
  cache->clear("CATEGORIES_");
}

public object get_fbobject(array args, Request|void id)
{
   array r;
   string a = args*"/";

   r=cache->get("PATHOBJECTCACHE_" + a);

   if(r && sizeof(r)) return r[0];

   r = Fins.Model.find.objects((["path": a]));

   if(sizeof(r))
   {
     cache->set("PATHOBJECTCACHE_" + a, r, 600);
     return r[0];
   }
   else return 0;
}

public string get_when(object c)
{
   string howlongago;
   int future;

   if (c < Calendar.now()) {
     c = c->distance(Calendar.now());
   }
   else {
     c = Calendar.now()->distance(c);
     future++;
   }

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

   if (future)
     return replace(howlongago, "ago", "in the future");
   else
     return howlongago;
}

int new_from_string(string path, string contents, string type, int|void att, int|void skip_if_exists)
{
  int isnew = 1;
  object obj_o;
  array dtos = Fins.Model.find.datatypes((["mimetype": type]));
               if(!sizeof(dtos))
               {
                  throw(Error.Generic("Mime type " + type + " not valid."));
               }
               else{
               object dto = dtos[0];
  mixed a;
  catch(a=Fins.Model.find.objects((["path": path]) ));
  if(a && sizeof(a))
  {
    if(skip_if_exists) return 0;
    obj_o  = a[0];
    isnew=0;
  }
  else
               obj_o = Fins.Model.new("object");
               obj_o["datatype"] = dto;
               if(att)
                 obj_o["is_attachment"] = 1;
               else 
                 obj_o["is_attachment"] = 0;
               obj_o["author"] = Fins.Model.find.users_by_id(1);
               obj_o["datatype"] = dto;
               obj_o["path"] = path;
           if(isnew)
            obj_o->save();

            object obj_n = Fins.Model.new("object_version");
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
            obj_n["author"] = Fins.Model.find.users_by_id(1);
            obj_n->save();
            return 1;

            }
  
}
