import Tools.Logging;
inherit Fins.Model.DirectAccessInstance;

string type_name = "object";
object repository = FinScribe.Repo;

   int is_readable(object user)
   {
     return has_xmit(user, "read", user && (user["id"] == this["author"]["id"]));
   }

   int is_postable(object user)
   {
     return has_xmit(user, "post", user && (user["id"] == this["author"]["id"]));
   }

   int has_xmit(object user, string xmit, int|void is_owner)
   {
     foreach(this["acl"]["rules"];; object rule)
       if(rule->has_xmit(user, xmit, is_owner))
         return 1;
     return 0;	
   }

   int is_deleteable(object user)
   {
     return has_xmit(user, "delete", user && (user["id"] == this["author"]["id"]));

   }

   int is_editable(object user)
   {
     if(user && this["md"]["locked"] && user["id"] != this["author"]["id"]) return 0;
     else return has_xmit(user, "version", user["id"] == this["author"]["id"]);
   }

   int is_writeable(object user)
   {
     return has_xmit(user, "write", user["id"] == this["author"]["id"]);
   }

   int is_lockable(object user)
   {
     return has_xmit(user, "lock", user["id"] == this["author"]["id"]);
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
