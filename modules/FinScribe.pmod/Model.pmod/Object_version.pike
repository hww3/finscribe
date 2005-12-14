import Fins;
import Fins.Model;

   inherit Model.DataObject;

   static void create(DataModelContext c)
   {  
      ::create(c);
      set_table_name("object_versions");
      set_instance_name("object_version");
      add_field(PrimaryKeyField("id"));
      add_field(KeyReference("object", "object_id", "object"));
      add_field(KeyReference("author", "author_id", "user"));
      add_field(IntField("version", 0, 1));
      add_field(StringField("subject", 128, 1));
      add_field(TransformField("content_length", "contents", lambda(mixed n, object i){return sizeof(n);}));
      add_field(StringField("contents", 102400, 0));
      add_field(DateTimeField("created", 0, created));
      add_field(TransformField("nice_created", "created", lambda(mixed n, object i){ return n->format_time();}));
      add_field(InverseForeignKeyReference("comments", "comment", "object"));

      set_primary_key("id");
   }

   static object created()
   {
     return Calendar.Second();
   }

