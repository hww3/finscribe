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

  array keys, values;

  keys = Array.everynth(f, 2);
  values = Array.everynth(f, 2, 1);

  keys = ({obj["path"]}) + keys;
  values = ({obj["title"]}) + values;

  keys = Array.uniq(keys)
  values = Array.uniq(values);

  if(sizeof(keys) > 10)
  {
    keys = keys[0..9];
    values = values[0..9];
  }

  f = Array.splice(key, values);

  p["Value"] = f*"\n";

  werror("value: " + p["Value"] + ".\n");

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

  array keys, values;

  keys = Array.everynth(f, 2);
  values = Array.everynth(f, 2, 1);

  if(sizeof(keys) != sizeof(values)) return ({});

  foreach(keys; int i; string v)
  {
    if(values[i])
      res += ({"<li><a href=\"/space/" + v + "\">" + values[i] + "</a>\n"});
  }

  return res;
}

}
