import Tools.Logging;
inherit Fins.Model.DirectAccessInstance;

string type_name = "object";
object repository = FinScribe.Repo;


   int is_readable(object user)
   {
     return 1;
   }

   int is_deleteable(object user)
   {
     if(!user) return 0;
     if(user["id"] == this["author"]["id"] || user["is_admin"]) return 1;
     else return 0;
   }

   int is_editable(object user)
   {
     if(!user) return 0;
     if(this["md"]["locked"] && user["id"] != this["author"]["id"]) return 0;
     else return 1;
   }

   int is_lockable(object user)
   {
     if(!user) return 0;
     if(user["id"] == this["author"]["id"] || user["is_admin"]) return 1;
     else return 0;
   }


public array get_blog_entries(int|void max)
{
  Log.debug("Getting blog entries for " + this["path"]);
  array o = FinScribe.Repo.find("object", ([ "is_attachment": 2, "parent": this]),
                        Fins.Model.Criteria("ORDER BY path DESC" + (max?(" LIMIT " + max) : "")));

  return o;
}

public string get_object_contents(Fins.Request|void id)
{

   return this["current_version"]["contents"];
}

mixed get_metadata()
{
  return this["md"];
}

void set_metadata(mixed metadata)
{
  this_object()["metadata"] = MIME.encode_base64(encode_value(metadata));
}
