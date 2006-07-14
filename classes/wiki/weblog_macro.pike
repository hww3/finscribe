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
  int start = 1;
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

  if(params->extras->request)
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

  // if we're starting somewhere in the middle, we should note that.
  if(params->extras && params->extras->request && 
           params->extras->request->variables->start)
    start = (int)(params->extras->request->variables->start);

  o = root->get_blog_entries(limit, start);

  //werror("LIMIT: %O, START: %O\n", limit, start);

  foreach(o; int i; object entry)
  {
    //werror("ENTRY: %O\n", entry["path"]);
    object t;
    t = params->engine->wiki->view->get_view("space/weblogentry");


    t->add("entry", entry);
    string s = entry["current_version"]["subject"];
    if(!s || !strlen(s)) s = "No Subject";
    t->add("subject", s);

    string contents = params->engine->render(entry["current_version"]["contents"], (["request": params->extras->request, "obj": entry]));
    t->add("contents", contents);
    if (sizeof(contents / "<!--break-->") > 1) 
      t->add("teaser", (contents / "<!--break-->")[0]);
    else
      t->add("teaser", contents);

  
    res += ({t->render()});
  }


  if(start && start > 1)
  {
    int nstart = start;
    if((start - limit)< 1) nstart = 1;
      else nstart = start-limit;
    res+=({"<a href=\"?weblog=partial&start=" + nstart + "\">Newer Entries</a> | "});
  }
  else
  {
    res += ({"Newer Entries | "});
  }

  int end = root->get_blog_count();

  if(start > end || start+limit > end)
  {
    res += ({"Older Entries | "});
  }
  else
  {
    int nstart = start + limit;
    res+=({"<a href=\"?weblog=partial&start=" + nstart + "\">Older Entries</a> | "});
  }


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
      if(extras->request)
        extras->request->misc->object_is_weblog = 1;
      return ({""});
    }

    string _sprintf(mixed t)
    {
      return "WeblogReplacer()";
    }
  }
