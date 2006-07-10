import Fins;
import Fins.Model;

   inherit Model.DataObject;

   static void define()
   {  
      set_table_name("groups");
      set_instance_name("group");
      add_field(PrimaryKeyField("id"));
      add_field(StringField("Name", 36, 0));
      add_field(MultiKeyReference(this, "users", 
          "users_groups", "group_id", "user_id", "user", "id"));
      add_field(MultiKeyReference(this, "groups", 
          "groups_groups", "group_id", "member_id", "group", "id"));
      set_primary_key("id");
   }
