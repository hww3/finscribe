import Fins;
import Fins.Model;

   inherit Model.DataObject;

   static void create(DataModelContext c)
   {  
      ::create(c);
      set_table_name("aclrules");
      set_instance_name("aclrule");
      add_field(PrimaryKeyField("id"));

      add_field(IntField("xmit", 8, 0, 0));
      add_field(StringField("custom_name", 8, 1, 0));

      add_field(MultiKeyReference(this, "user",
          "aclrules_users", "aclrule_id", "user_id", "user", "id"));
      add_field(MultiKeyReference(this, "group",
          "aclrules_groups", "aclrule_id", "group_id", "group", "id"));

      set_primary_key("id");
   }
