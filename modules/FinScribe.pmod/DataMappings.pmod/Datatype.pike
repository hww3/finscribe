import Fins;
import Fins.Model;

   inherit Model.DataObject;

   static void post_define(object context)
   {  
      add_field(context, TransformField("value", "mimetype", lambda(mixed a){return a;}));
      set_alternate_key("mimetype");
   }
