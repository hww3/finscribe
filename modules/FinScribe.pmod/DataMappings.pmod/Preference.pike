import Fins;
import Fins.Model;

   inherit Model.DataObject;

   static void post_define(object context)
   {  
      add_field(context, TransformField("shortname", "name", lambda(mixed n, object i){return (n/".")[-1];}));
      add_field(context, TransformField("booleanvalue", "value", lambda(mixed n, object i){return (((int)n)?"true":"false");}));
      add_field(context, TransformField("yesnovalue", "value", lambda(mixed n, object i){return (((int)n)?"Yes":"No");}));
      add_field(context, TransformField("typedvalue", "value", typedvalue));
      set_alternate_key("name");
   }


   mixed typedvalue(mixed n, object i)
   {
      if(i["type"] == FinScribe.BOOLEAN)
        return (int)n;
      else return n;
   }
