import Fins;
import Fins.Model;

   inherit Model.DataObject;

   static void create(DataModelContext c)
   {  
      ::create(c);
      set_table_name("aclrules");
      set_instance_name("aclrule");
      add_field(PrimaryKeyField("id"));

      // permit bits are follows:
      //    bit 1: browse
      //    bit 2: read
      //    bit 3: version
      //    bit 4: write (create)
      //    bit 5: delete
      add_field(IntField("xmit", 8, 0, 0));

      add_field(TransformField("browse", "xmit", get_browse));
      add_field(TransformField("read", "xmit", get_read));
      add_field(TransformField("version", "xmit", get_version));
      add_field(TransformField("write", "xmit", get_write));
      add_field(TransformField("delete", "xmit", get_delete));

      add_field(StringField("custom_name", 8, 1, 0));

      add_field(MultiKeyReference(this, "user",
          "aclrules_users", "aclrule_id", "user_id", "user", "id"));
      add_field(MultiKeyReference(this, "group",
          "aclrules_groups", "aclrule_id", "group_id", "group", "id"));

      set_primary_key("id");
   }


   string get_browse(mixed n, object i)
   {
     return n&1;
   }

   string get_read(mixed n, object i)
   {
     return n&2;
   }

   string get_version(mixed n, object i)
   {
     return n&4;
   }

   string get_write(mixed n, object i)
   {
     return n&8;
   }

   string get_delete(mixed n, object i)
   {
     return n&16;
   }

