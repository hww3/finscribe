import Public.Web.Wiki;
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

  logger->info("updating recent changes list.\n");

//  // we don't care about work in progress items.
  if(obj["is_attachment"] > 2) return 0; 

  object p = id->fins_app->new_string_pref("plugin.recentchanges.list", "");

  f = p->get_value()/"\n";


  f = ({(string)(obj["id"])}) + f;
  f = Array.uniq(f);

  if(sizeof(f) > 5)
  {
    f = f[0..4];
  }

  p["value"] = f*"\n";

//  werror("value: " + p["value"] + ".\n");

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
    catch(ent = Fins.DataSource._default.find.objects_by_id((int)k));
      if(!ent /*|| !ent->is_browseable()*/) continue;
      res += ({"<li><a href=\"/space/" + ent["path"] + "\">" + ent["title"] + "</a></li>\n"});
  }

  return ({ "<ul class=\"recent_changes\">" }) + res + ({ "</ul> "});
}

}
