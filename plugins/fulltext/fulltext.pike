import Tools.Logging;

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

int updateIndex(string event, object id, object obj)
{
  Log.info("saved " + obj["path"]);  

  object c = Protocols.XMLRPC.Client("http://buoy.riverweb.com:9001/update/?PSESSIONID=123");

  werror("%O\n", c["delete_by_handle"](app->config["site"]["url"], 
obj["path"]));  
  c["add"](app->config["site"]["url"], obj["title"], 
obj["current_version"]["created"]->unix_time(), 
obj["title"] + " " + obj["current_version"]["contents"], obj["path"]);

  return 0;
}
