import Fins;
import Fins.Model;

   inherit Model.DataObject;

   static void post_define()
   {  
      add_field(TransformField("shortname", "name", lambda(mixed n, object i){return (n/".")[-1];}));
      add_field(TransformField("booleanvalue", "value", lambda(mixed n, object i){return (((int)n)?"true":"false");}));
      set_alternate_key("name");
   }
