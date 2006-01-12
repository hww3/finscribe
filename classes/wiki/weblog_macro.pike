import Public.Web.Wiki;
import Fins;
inherit Macros.Macro;

string describe()
{
   return "Produces a weblog";
}

array evaluate(Macros.MacroParameters params)
{
  object root;
  int limit;
  array res = ({});
// werror("EVALUATE: %O\n", params->extras->obj);

  if(params->extras->obj && !stringp(params->extras->obj))
    root = params->extras->obj;
  else
  {
    array o = params->engine->wiki->model->find("object", (["path": params->extras->obj["path"]]));
    if(sizeof(o))
      root = o[0];
  }

  params->extras->request->misc->object_is_weblog = 1;

  // we should get a limit for the number of entries to display.

  array a = params->parameters / "|";
  if(sizeof(a) && a[0] && strlen(a[0]))
    limit = (int)a[0];
  else limit = 10;

  if(!root)
  {
    return ({"Unable to render Weblog because the weblog page location could not be determined."}); 
  } 
//werror("root: %O\n", object_program(root));

  array o;

  if(params->extras && params->extras->request && params->extras->request->variables->weblog =="full")
    o = root->get_blog_entries();
  else
    o = root->get_blog_entries(limit);

  foreach(o; int i; object entry)
  {
    object t;
    t = params->engine->wiki->view->get_view("space/weblogentry");


    t->add("entry", entry);
    string s = entry["current_version"]["subject"];
    if(!s || !strlen(s)) s = "No Subject";
    t->add("subject", s);

    t->add("contents", params->engine->render(entry["current_version"]["contents"], (["request": params->extras->request, "obj": entry])));

  
    res += ({t->render()});
  }

  if(params->extras && params->extras->request && params->extras->request->variables->weblog =="full")
    res+=({"<a href=\"?weblog=recent\">Recent Entries...</a> | "});
  else
    res+=({"<a href=\"?weblog=full\">More Entries...</a> | "});
  res+=({"<a href=\"/rss/"});
  res+=({root["path"]});
  res+=({"\">RSS Feed</a>"});
  res+=({WeblogReplacerObject()});

  return res;
}


  class WeblogReplacerObject()
                                                {

                                                        array render(object engine, mixed extras)
                                                        {
								extras->request->misc->object_is_weblog = 1;
                                                                return ({""});
                                                        }

                                                        string _sprintf(mixed t)
                                                        {
                                                                return "WeblogReplacer()";
                                                        }
                                                }
