import Fins;
import Fins.Model;

   inherit Model.DataObject;

   static void post_define(object context)
   {  
      add_field(context, TransformField("content_length", "contents", lambda(mixed n, object i){return sizeof(n);}));
      add_field(context, TransformField("nice_content_length", "contents", lambda(mixed n, object i){int z = sizeof(n); if(z < 1024) return z + " bytes"; else if (z < 1024000) return (z / 1024) + " kb"; else return (z / 1024000) + " mb";}));

//      add_field(context, BinaryStringField("contents", 1024000, 0));

      add_field(context, TransformField("nice_created", "created", lambda(mixed n, object i){ return n->format_time();}));

      set_alternate_key("version");
   }
