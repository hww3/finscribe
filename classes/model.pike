import Fins;
import Fins.Model;
inherit Fins.FinsModel;

object repository = FinScribe.Repo;

public void load_model()
{
//  if(!config["app"] || !config["app"]["installed"]) return;

  ::load_model();

   FinScribe.Repo.add_object_type(FinScribe.Model.Object_object(context), FinScribe.Model.Object);
   FinScribe.Repo.add_object_type(FinScribe.Model.Object_version_object(context), FinScribe.Model.Object_version);
   FinScribe.Repo.add_object_type(FinScribe.Model.Datatype_object(context), FinScribe.Model.Datatype);   
   FinScribe.Repo.add_object_type(FinScribe.Model.Category_object(context), FinScribe.Model.Category);
   FinScribe.Repo.add_object_type(FinScribe.Model.Comment_object(context), FinScribe.Model.Comment);
   FinScribe.Repo.add_object_type(FinScribe.Model.User_object(context), FinScribe.Model.User);
   FinScribe.Repo.add_object_type(FinScribe.Model.Group_object(context), FinScribe.Model.Group);
   FinScribe.Repo.add_object_type(FinScribe.Model.ACL_object(context), FinScribe.Model.ACL);
   FinScribe.Repo.add_object_type(FinScribe.Model.ACLRule_object(context), FinScribe.Model.ACLRule);
}

Model.DataObjectInstance find_by_id(string|object ot, int id)
{
  return FinScribe.Repo.find_by_id(ot, id);
}

array find(string|object ot, mapping attr, object|void criteria)
{
  return FinScribe.Repo.find(ot, attr, criteria);
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

  res = FinScribe.Repo.find("datatype", ([]));

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
{
  obj["metadata"] = encode_value(metadata);
}

mixed get_categories()
{
  mixed res;

  res = cache->get("CATEGORIES_");
  
  if(res) return res;

  res = FinScribe.Repo.find("category", ([]));

  cache->set("CATEGORIES_", res, 600);

  return res;
}

public object get_fbobject(array args, Request|void id)
{
   array r;
   string a = args*"/";

   r=cache->get("PATHOBJECTCACHE_" + a);

   if(r && sizeof(r)) return r[0];

   r = FinScribe.Repo.find("object", (["path": a]));

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

int new_from_string(string path, string contents, string type, int|void att, int|void skip_if_exists)
{
  int isnew = 1;
  object obj_o;
  array dtos = FinScribe.Repo.find("datatype", (["mimetype": type]));
               if(!sizeof(dtos))
               {
                  throw(Error.Generic("Mime type " + type + " not valid."));
               }
               else{
               object dto = dtos[0];
  mixed a;
  catch(a=FinScribe.Repo.find("object", (["path": path]) ));
  if(a && sizeof(a))
  {
    if(skip_if_exists) return 0;
    obj_o  = a[0];
    isnew=0;
  }
  else
               obj_o = FinScribe.Repo.new("object");
               obj_o["datatype"] = dto;
               if(att)
                 obj_o["is_attachment"] = 1;
               else 
                 obj_o["is_attachment"] = 0;
               obj_o["author"] = FinScribe.Repo.find("user", (["UserName": "admin"]))[0];
               obj_o["datatype"] = dto;
               obj_o["path"] = path;
           if(isnew)
            obj_o->save();

            object obj_n = FinScribe.Repo.new("object_version");
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
            obj_n["author"] = FinScribe.Repo.find("user", (["UserName": "admin"]))[0];
            obj_n->save();
            return 1;

            }
  
}
