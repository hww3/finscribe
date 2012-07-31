import Fins;
import Fins.Model;

   inherit Model.DataObject;

   static void post_define(object context)
   {  
      add_field(context, TransformField("shortname", "name", lambda(mixed n, object i){return (n/".")[-1];}));
      add_field(context, TransformField("booleanvalue", "value", lambda(mixed n, object i){return (((int)n)?"true":"false");}));
      add_field(context, TransformField("yesnovalue", "value", lambda(mixed n, object i){return (((int)n)?"Yes":"No");}));
      add_field(context, TransformField("typedvalue", "value", typedvalue));
      add_field(context, TransformField("def", "name", getprefdef));
      add_field(context, TransformField("basename", "name", getbasename));
      set_alternate_key("name");
   }

   mixed getbasename(mixed n, object i)
   {
     if(i["user_pref"]) 
     {
       int l = search(n, ".");
       if(l==-1)
        return 0; // ERROR!
       return "user." + n[l+1..];
      
     }
     else
     {
       return i["name"];
     }
   }


   mixed getprefdef(mixed n, object i)
   {
     return(i->context->app->get_preference_definition(i));
   }

   mixed typedvalue(mixed n, object i)
   {
      if(i["type"] == FinScribe.BOOLEAN)
        return (int)n;
      else return n;
   }
