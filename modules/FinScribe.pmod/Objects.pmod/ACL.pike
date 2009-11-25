inherit Fins.Model.DirectAccessInstance;

string type_name = "ACL";

   int has_xmit(object user, string xmit, int|void is_owner)
   {
     foreach(this["rules"];; object rule)
       if(rule->has_xmit(user, xmit, is_owner))
         return 1;
     return 0;
   }
