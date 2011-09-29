import Fins;
import Fins.Model;

   inherit Model.DataObject;

   static void post_define(object context)
   {    
      set_alternate_key("name");
   }
