import Public.Web.Wiki;
import Fins;
inherit Macros.Macro;

//
// args: 
//
// path - specify the path of the weblog to display. defaults to current page.
// limit - how many entries to list on each page.
// quiet - if set to true, supresses the navigation elements
// template - use the named template in space folder to display each entry.
//
// if content contains a <!-- break --> comment, the portion before the break
// will be available in the template as <%$teaser%>
//

string describe()
{
   return "Produces a weblog, args: path, limit, quiet, template";
}

array evaluate(Macros.MacroParameters params)
{
  object root;
  int limit;
  int start = 1;
  array res = ({});
  string template = "weblogentry";

  params->make_args();

  if(params->args->template)
    template = params->args->template;

  if(params->args->path)
  {
    root = Fins.DataSource._default.find.objects_by_path(params->args->path);
  }
  if(!root)
  {
    if( params->extras->obj && !stringp(params->extras->obj))
    root = params->extras->obj;
    else
    {
      array o = Fins.DataSource._default.find.objects((["path": params->extras->obj["path"]]));
      if(sizeof(o))
        root = o[0];
    }
  }
//werror("params: %O\n", mkmapping(indices(params), values(params)));
//werror("root: %O\n", root);

  if(params->extras->request)
  {
    params->extras->request->misc->object_is_weblog = 1;
//    params->extras->request->misc->template_data->add("object_is_weblog", 1);
  }
  // we should get a limit for the number of entries to display.


  if(params->args->limit)
    limit = (int)params->args->limit;
  else limit = 10;

  if(!root)
  {
    return ({"Unable to render Weblog because the weblog page location could not be determined."}); 
  } 

  array o;

  // if we're starting somewhere in the middle, we should note that.
  if(params->extras && params->extras->request && 
           params->extras->request->variables->start)
  {
    params->extras->request->misc->render_no_cache = 1;
    start = (int)(params->extras->request->variables->start);
  }
  o = root->get_blog_entries(limit, start);

  //werror("LIMIT: %O, START: %O\n", limit, start);

  foreach(o; int i; object entry)
  {
    //werror("ENTRY: %O\n", entry["path"]);
    object t;
    t = params->engine->wiki->view->get_view("space/" + template);


    t->add("entry", entry);
    string s = entry["current_version"]["subject"];
    if(!s || !strlen(s)) s = "No Subject";
    t->add("subject", s);

    string contents = entry["current_version"]["contents"];

    t->add("content", contents);
    if (sizeof(contents / "<!--break-->") > 1) 
      t->add("teaser", (contents / "<!--break-->")[0]);
    else
      t->add("teaser", contents);

  
    res += ({t->render()});
  }

  if(!params->args->quiet)
  {
    res += ({ "<div class=\"pager\">" });
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
    res+=({ "</div>" });
  }

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
