import Fins;
import Fins.Model;

inherit Model.DataObject;

static void post_define(object context)
{  
  has_many(context, "Object", "objects", "author");
  has_many(context, "Object_version", "versions", "author");
  has_many(context, "Comment", "comments", "author");

  set_alternate_key("username");
}


void validate(mapping changes, object er, object instance)
{
  write("changes: %O\n", changes);
  if(changes["email"] && sizeof(changes["email"]) && !Regexp("[A-Za-z0-9_\\-]@(.*)\\.(.*)")->match(changes["email"]))
    er->add("Email address is invalid (" + changes["email"] + ").");
}



