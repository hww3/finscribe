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


public int get_blog_count()
{
  array o = master_object->context->sql->query("SELECT COUNT(*) as foo FROM objects WHERE parent_id=" + 
                     this["id"] + " AND is_attachment=2");
  return (int)(o[0]->foo);

}

public array get_blog_entries(int|void max, int|void start)
{
  Log.debug("Getting blog entries for " + this["path"]);
  array crit = ({});

  crit += ({Fins.Model.Criteria("ORDER BY path DESC")});

  if(max||start) crit += ({Fins.Model.LimitCriteria(max, start)});

  array o = FinScribe.Repo.find("object", ([ "is_attachment": 2, "parent": this]),
                        Fins.Model.CompoundCriteria( crit )
            );

  return o;
}

public array get_attachments(int|void max, int|void start)
{
  Log.debug("Getting attachments for " + this["path"]);
  array crit = ({});

  crit += ({Fins.Model.Criteria("ORDER BY path DESC")});

  if(max||start) crit += ({Fins.Model.LimitCriteria(max, start)});

  array o = FinScribe.Repo.find("object", ([ "is_attachment": 1, "parent": this]),
                        Fins.Model.CompoundCriteria( crit )
            );

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
