import Fins;
import Fins.Model;

   inherit Model.DataObject;

   static void define()
   {  
      set_table_name("preferences");
      set_instance_name("preference");
      add_field(PrimaryKeyField("id"));
      add_field(StringField("Name", 64, 0));
      add_field(IntField("Type", 1, 0));
      add_field(StringField("Value", 1024, 0));
      add_field(TransformField("BooleanValue", "Value", lambda(mixed n, object i){return (((int)n)?"true":"false");}));
      set_primary_key("id");
   }
