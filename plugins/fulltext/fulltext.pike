import Tools.Logging;
import Public.Web.Wiki;

inherit FinScribe.Plugin;

constant name="Full Text indexing";

int _enabled = 0;

mapping query_event_callers()
{
  return (["postSave": updateIndex ]);
}

mapping query_ipath_callers()
{
  return (["ftsearch": ftSearch ]);
}

mapping query_macro_callers()
{
  return ([ "search-dialog": searchdialog_macro(),
            "search-results": searchresults_macro() ]);
}

void ftSearch(object id, object response, mixed ... args)
{
  if(!id->variables->q)
  {
    response->set_data("ftsearch: no query specified.");
    return;
  }

  else
  {
    object c = Protocols.XMLRPC.Client(app->config["fulltext"]["indexserver"]+"/search/?PSESSIONID=123");
    array r = c["search"](app->get_sys_pref("site.url")["Value"], id->variables->q, "contents");

    if(r[0] && sizeof(r[0]))
    {
      response->set_data(sprintf("<pre>%O</pre>\n", r[0]));
    }
    else 
    {
      response->set_data("no results for your query.");
    }
  }
}

string textify(string html)
{
  object p = Parser.HTML();
  p->_set_tag_callback(lambda(object parser, mixed val){return "";});

  return p->finish(html)->read();
}

int updateIndex(string event, object id, object obj)
{
  call_out(Thread.Thread, 0, doUpdateIndex, event, id, obj);

  return 0;
}

void doUpdateIndex(string event, object id, object obj)
{
  if(obj["is_attachment"] == 3) return;

  Log.info("saved " + obj["path"]);  

  object p = app->get_sys_pref("plugin." + name + ".indexserver");
  if(!p) return 0;

  object c = Protocols.XMLRPC.Client(p->get_value() + "/update/");

  string t = textify(app->render(obj["current_version"]["contents"], obj, id));
  if(obj["path"] && strlen(obj["path"]))
  werror("deleteions: %O\n", 
  c["delete_by_handle"](app->get_sys_pref("site.url")->get_value(), obj["path"]));  
  c["add"](app->get_sys_pref("site.url")->get_value(), obj["title"], 
      obj["current_version"]["created"]->unix_time(), 
      obj["title"] + " " + t, obj["path"], 
      FinScribe.Blog.make_excerpt(t));
}

class searchdialog_macro
{

inherit Macros.Macro;

string describe()
{
   return "Displays a search dialog";
}

array evaluate(Macros.MacroParameters params)
{
  int limit;

  array res = ({});
  string target_url;

  array a = params->parameters / "|";

  if(!sizeof(a) || !strlen(a[0]))
  {
    return ({"No Search Result page specified!\n"});
  }

  foreach(a;;string val)
  {
    if(has_prefix(val, "target_url="))
    {
      target_url = val[11..];
    }
  }

  res+=({"<div class=\"search-dialog\">\n"});
  res+=({"<form action=\"" + target_url + "\">\n" });

  res+=({"<input type=\"text\" name=\"q\"> <input type=\"submit\" value=\"Search\">"});

  res+=({"</form>\n"});
  res+=({"</div>\n"});

  return res;
}

}

class searchresults_macro
{

inherit Macros.Macro;

string describe()
{
   return "Displays a set of search results";
}

array doSearchMacro(Macros.MacroParameters params)
{
  int limit;

  array res = ({});
  string target_url;


  if(!params || !params->extras->request || !params->extras->request->variables->q)
    return ({"No query specified."});

  object c = 
Protocols.XMLRPC.Client(params->extras->request->fins_app->config["fulltext"]["indexserver"]+ "/search/?PSESSIONID=123");
  mixed r =
c["search"](params->extras->request->fins_app->get_sys_pref("site.url")["Value"],
params->extras->request->variables->q, "contents");
  res+=({"<div class=\"search-results\">\n"});

  if(objectp(r))
  {
    res += ({ "<b>Searching failed, with the following response from the index server:</b><p>"  });  
    res += ({ r->fault_string });  
  }
  else if(!sizeof(r[0])) 
  {
    res += ({ "<b>No documents found</b><p>" });
  }  
  else
  {
    object user = params->engine->wiki->get_current_user(params->extras->request);
    res += ({ "<b>Search results:</b><p>" });
    foreach(r[0];int i; mapping entry)
    {
      array o = params->engine->wiki->model->find("object", (["path": entry->handle]));
      if(!sizeof(o)) continue;
      object e = o[0];
      if(e->is_readable(user))
        res += ({ "<img src=\"/static/images/attachment/" + e["icon"] + "\"> <a href=\"/space/" 
              + entry->handle + "\">" + entry->title + 
              "</a> (" + entry->date + ")  [" + (int)(entry->score * 100.0)+ "%]<dd>\n" + entry->excerpt + "</dd><p>\n"});
    }
  }
  res+=({"</div>\n"});

  return res;

}

array evaluate(Macros.MacroParameters params)
{
  return ({"",  SearchResultReplacerObject(doSearchMacro, params), ""});
}


  class SearchResultReplacerObject(function f, object params)
                                                {

                                                        array render(object engine, mixed extras)
                                                        {
                                                             object p = Public.Web.Wiki.Macros.MacroParameters();
                                                             p->engine = engine;
                                                             p->extras = extras;
                                                             p->contents = params->contents;
                                                             p->parameters = params->parameters;
                                                            return f(p);
                                                        }

                                                        string _sprintf(mixed t)
                                                        {
                                                                return "SearchResultReplacer()";
                                                        }
                                                }





}

