import Fins;
import Fins.Model;

   inherit Model.DataObject;

   static void create(DataModelContext c)
   {  
      ::create(c);
      set_table_name("aclrules");
      set_instance_name("aclrule");
      add_field(PrimaryKeyField("id"));

      add_field(IntField("x_read", 1, 1));
      add_field(IntField("x_annotate", 1, 1));
      add_field(IntField("x_write", 1, 1));
      add_field(IntField("x_delete", 1, 1));
      add_field(IntField("x_exec", 1, 1));

      add_field(MultiKeyReference(this, "user",
          "aclrules_users", "aclrule_id", "user_id", "user", "id"));
      add_field(MultiKeyReference(this, "group",
          "aclrules_groups", "aclrule_id", "group_id", "group", "id"));

      set_primary_key("id");
   }
