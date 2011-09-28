import Fins;
import Fins.Model;
inherit Fins.FinsModel;
import Tools.Logging;

int lower_case_link_names = 1;

//! @deprecated
DataModelContext context;

//object datatype_instance_module = FinScribe.Objects;
//object datatype_definition_module = FinScribe.DataMappings;

//object repository = FinScribe.Repo;

// because we might be starting the app in "install mode", we 
// override the default loader to check for that scenario.
public void load_model()
{
  if(!config["application"] || !config["application"]["installed"]) 
  {
    Log.info("Not starting model.\n");
    return 0;
  }
  else
  {
    Log.info("Starting model.\n");
  }

  ::load_model();

  // context is used by some legacy code, so we'll manually populate it (for now);
  context = Fins.Model.get_default_context();
}

//! given a path p, find the path component closest to p that represents
//! an actual object. if none exists, return 0.
Model.DataObjectInstance find_nearest_parent(string path)
{
  array a = path/"/";

  for(int i = sizeof(a); i != 0; i--)
  {
    string p = (a[0..(i-1)] * "/");
    mixed o = context->find->objects((["path": p]));
    if(sizeof(o)) return o[0];
  }

  return 0;
}

// return the last component of a path.
// for example, get_object_name("/path/to/document") would return "document".
string get_object_name(string n)
{
  return (n/"/")[-1];
}

//! a cache-enabled version of find.datatypes_all().
mixed get_datatypes()
	{
  mixed res;

  res = cache->get("DATATYPES_");
  
  if(res) return res;

  res = context->find->datatypes_all();

  cache->set("DATATYPES_", res, 600);

  return res;
}

//! decode the metadata field in object obj.
mixed get_metadata(object obj)
{
  string md = obj["metadata"];
  if(md && strlen(md))  
    return decode_value(md);
  else return ([]);
}

//! encode the data metadata into the metadata field in object obj.
void set_metadata(object obj, mixed metadata)
{  obj["metadata"] = encode_value(metadata);
}

//! a cache-enabled version of find.categories_all().
mixed get_categories()
{
  mixed res;

  res = cache->get("CATEGORIES_");
  
  if(res) return res;

  res = context->find->categories_all();

  cache->set("CATEGORIES_", res, 600);

  return res;
}

//! clear the category cache
void clear_categories()
{
  cache->clear("CATEGORIES_");
}

//! a cache enabled version of find.objects_by_alt()
public object get_fbobject(array args, Request|void id)
{
   object r;
   string a = args*"/";

   r=cache->get("PATHOBJECTCACHE_" + a);

   if(r) return r;

   mixed e = catch(r = context->find->objects_by_path(a));

   // TODO: we should do something with the error rather than just swallow it.

   if(r)
   {
     cache->set("PATHOBJECTCACHE_" + a, r, 600);
     return r;
   }
   else return 0;
}

function get_when = Tools.String.friendly_date;

//! convenience function used by installer.
int new_from_string(string path, string contents, string type, int|void att, int|void skip_if_exists)
{
  int isnew = 1;
  object obj_o;
  array dtos = context->find->datatypes((["mimetype": type]));
               if(!sizeof(dtos))
               {
                  throw(Error.Generic("Mime type " + type + " not valid."));
               }
               else{
               object dto = dtos[0];
  mixed a;
  catch(a = context->find->objects((["path": path]) ));
  if(a && sizeof(a))
  {
    if(skip_if_exists) return 0;
    obj_o  = a[0];
    isnew=0;
  }
  else
               obj_o = FinScribe.Objects.Object();
               obj_o["datatype"] = dto;
               if(att)
                 obj_o["is_attachment"] = 1;
               else 
                 obj_o["is_attachment"] = 0;
               obj_o["author"] = context->find->users_by_id(1);
               obj_o["datatype"] = dto;
               obj_o["path"] = path;
           if(isnew)
            obj_o->save();

            object obj_n = FinScribe.Objects.Object_version();
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
            obj_n["author"] = context->find->users_by_id(1);
            obj_n->save();
            return 1;

            }
}
