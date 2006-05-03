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
      //    bit 6: comment/annotate
      //    bit 7: post
      //    bit 8: lock

      add_field(IntField("xmit", 8, 0, 0));

      add_field(TransformField("browse", "xmit", get_browse));
      add_field(TransformField("read", "xmit", get_read));
      add_field(TransformField("version", "xmit", get_version));
      add_field(TransformField("write", "xmit", get_write));
      add_field(TransformField("delete", "xmit", get_delete));
      add_field(TransformField("comment", "xmit", get_comment));
      add_field(TransformField("post", "xmit", get_post));
      add_field(TransformField("lock", "xmit", get_lock));

      // classes bits are follows:
      //     bit 1: owner
      //     bit 2: all users
      //     bit 3: anonymous
      add_field(IntField("class", 8, 0, 0));

      add_field(StringField("custom_name", 8, 1, 0));

      add_field(MultiKeyReference(this, "user",
          "aclrules_users", "aclrule_id", "user_id", "user", "id"));
      add_field(MultiKeyReference(this, "group",
          "aclrules_groups", "aclrule_id", "group_id", "group", "id"));

      set_primary_key("id");
   }


   int(0..1) get_browse(mixed n, object i)
   {
     return ((n&1)?1:0);
   }

   int(0..1) get_read(mixed n, object i)
   {
     return ((n&2)?1:0);
   }

   int(0..1) get_version(mixed n, object i)
   {
     return ((n&4)?1:0);
   }

   int(0..1) get_write(mixed n, object i)
   {
     return ((n&8)?1:0);
   }

   int(0..1) get_delete(mixed n, object i)
   {
     return ((n&16)?1:0);
   }

   int(0..1) get_comment(mixed n, object i)
   {
     return ((n&32)?1:0);
   }

   int(0..1) get_post(mixed n, object i)
   {
     return ((n&64)?1:0);
   }

   int(0..1) get_lock(mixed n, object i)
   {
     return ((n&128)?1:0);
   }
