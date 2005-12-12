import Fins;
import Fins.Model;

   inherit Model.DataObject;

   static void create(DataModelContext c)
   {  
      ::create(c);
      set_table_name("users");
      set_instance_name("user");
      add_field(PrimaryKeyField("id"));
      add_field(StringField("Name", 36, 0));
      add_field(StringField("UserName", 12, 0));
      add_field(StringField("Email", 64, 0));
      add_field(IntField("is_admin", 1, 1));
      add_field(IntField("is_active", 1, 1));
      add_field(StringField("Password", 16, 0));
      set_primary_key("id");
   }
