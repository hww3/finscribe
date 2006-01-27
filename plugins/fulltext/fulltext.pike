import Tools.Logging;
import Public.Web.Wiki;

inherit FinScribe.Plugin;

constant name="Full Text indexing";

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
    object c = Protocols.XMLRPC.Client("http://buoy.riverweb.com:9001/search/?PSESSIONID=123");
    array r = c["search"](app->config["site"]["url"], id->variables->q, "contents");

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
  Log.info("saved " + obj["path"]);  

  object c = Protocols.XMLRPC.Client("http://buoy.riverweb.com:9001/update/?PSESSIONID=123");

  werror("calling textify()\n");
  string t = textify(app->render(obj["current_version"]["contents"], obj, id));
  werror("textify() returned " + t + "\n");
  if(obj["path"] && strlen(obj["path"]))
  werror("deleteions: %O\n", 
c["delete_by_handle"](app->config["site"]["url"], obj["path"]));  
  c["add"](app->config["site"]["url"], obj["title"], 
      obj["current_version"]["created"]->unix_time(), 
      obj["title"] + " " + t, obj["path"], 
      FinScribe.Blog.make_excerpt(t));

  return 0;
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


  if(!params->extras->request->variables->q)
    return ({"No query specified."});

  object c = Protocols.XMLRPC.Client("http://buoy.riverweb.com:9001/search/?PSESSIONID=123");
  mixed r =
c["search"](params->extras->request->fins_app->config["site"]["url"],
params->extras->request->variables->q, "contents");
  res+=({"<div class=\"search-results\">\n"});

  if(objectp(r))
  {
    res += ({ "Searching failed, with the following response from the index server:<p>"  });  
    res += ({ r->fault_string });  
  }

  else
  {
    foreach(r[0];; mapping entry)
      res += ({ "<a href=\"/space/" + entry->handle + "\">" + entry->title + 
              "</a><br><dd>\n" + entry->excerpt + "</dd><p>\n"});
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

