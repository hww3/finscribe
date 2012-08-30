import Fins;
import Fins.Model;

   inherit Model.DataObject;

   static void post_define(object context)
   {  
	  belongs_to(context, "User", "author", "author_id");

      add_field(context, TransformField("content_length", "contents", lambda(mixed n, object i){return sizeof(n);}));
      add_field(context, TransformField("nice_content_length", "contents", lambda(mixed n, object i){int z = sizeof(n); if(z < 1024) return z + " bytes"; else if (z < 1024000) return (z / 1024) + " kb"; else return (z / 1024000) + " mb";}));

      add_field(context, FinScribe.FSBinaryStringField("contents", 1024*1024*10, 0), 1);

      add_field(context, TransformField("nice_created", "created", format_created));

      add_default_value(context, "created", created);

      set_alternate_key("version");
   }

   object created()
   {
     return Calendar.now()->second();
   }   
        
   string format_created(object c, object i)
   {
     return c->format_ext_ymd();
   }
