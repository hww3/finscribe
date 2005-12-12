import Fins;
import Fins.Model;

   inherit Model.DataObject;

   static void create(DataModelContext c)
   {  
      ::create(c);
      set_table_name("datatypes");
      set_instance_name("datatype");
      add_field(PrimaryKeyField("id"));
      add_field(StringField("mimetype", 32, 0));
      set_primary_key("id");
   }

   static object created()
   {
     return Calendar.Second();
   }

