inherit Fins.Model.Repository;


Fins.Model.DataObjectInstance find_by_id(string|object ot, int id)
{
   object o;
   string key = "";

   if(objectp(ot))
     key = sprintf("OBJECTCACHE_%s_%d", ot->instance_name, id);
   else key=sprintf("OBJECTCACHE_%s_%d", ot, id);

   o = FinScribe.Cache.get(key);

   if(o) return o;

   o = ::find_by_id(ot, id);
   if(o) FinScribe.Cache.set(key, o, 600);

   return o;
}


