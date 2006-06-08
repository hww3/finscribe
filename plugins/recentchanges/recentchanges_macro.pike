import Public.Web.Wiki;
import Tools.Logging;
import Fins;

inherit FinScribe.Plugin;

constant name="Recent Changes";

int _enabled = 1;

mapping query_event_callers()
{
  return (["postSave": updateList ]);
}

mapping query_macro_callers()
{
  return (["recent-changes": recentchanges_macro() ]);
}

int updateList(string event, object id, object obj)
{
  array f;

  werror("updating recent changes.\n");
 
  object p = id->fins_app->new_string_pref("plugin.recentchanges.list", "");

  f = p->get_value()/"\n";

  f = ({(string)(obj["id"])}) + f;
  f = Array.uniq(f);

  if(sizeof(f) > 5)
  {
    f = f[0..4];
  }

  p["Value"] = f*"\n";

//  werror("value: " + p["Value"] + ".\n");

  return 0;

}

class recentchanges_macro{

inherit Macros.Macro;

string describe()
{
   return "Recently Changed Objects";
}

array evaluate(Macros.MacroParameters params)
{
  array res = ({});

  array f = params->engine->wiki->new_string_pref("plugin.recentchanges.list", "")->get_value()/"\n";

  foreach(f;;string k)
  {
    if(!(int)k) continue;
  
    object ent;
    catch(ent = params->engine->wiki->model->find_by_id("object", (int)k));
      if(!ent) continue;
      res += ({"<li><a href=\"/space/" + ent["path"] + "\">" + ent["title"] + "</a>\n"});
  }

  return res;
}

}
