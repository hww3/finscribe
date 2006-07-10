import Fins;
import Fins.Model;

   inherit Model.DataObject;

   static void define()
   {  
      set_table_name("acls");
      set_instance_name("acl");
      add_field(PrimaryKeyField("id"));
      add_field(StringField("Name", 36, 0));
      add_field(MultiKeyReference(this, "rules", 
          "acls_rules", "acl_id", "rule_id", "aclrule", "id"));
      set_primary_key("id");
   }
