import Fins;
import Fins.Model;

   inherit Model.DataObject;

   static void define()
   {  
      set_table_name("users");
      set_instance_name("user");
      add_field(PrimaryKeyField("id"));
      add_field(StringField("Name", 36, 0));
      add_field(StringField("UserName", 12, 0));
      add_field(StringField("Email", 64, 0));
      add_field(IntField("is_admin", 1, 1));
      add_field(IntField("is_active", 1, 1));
      add_field(StringField("Password", 16, 0));
      add_field(MultiKeyReference(this, "groups",
          "users_groups", "user_id", "group_id", "group", "id"));
     add_field(InverseForeignKeyReference("objects", "object", "author"));
     add_field(InverseForeignKeyReference("object_versions", "object_version", "author"));
      set_primary_key("id");
      set_alternate_key("UserName");
   }


void validate(mapping changes, object er, object instance)
{
  if(changes["Email"] && !Regexp("[A-Za-z0-9_\\-]@(.*)\\.(.*)")->match(changes["Email"]))
    er->add("Email address is invalid (" + changes["Email"] + ").\n");
}



