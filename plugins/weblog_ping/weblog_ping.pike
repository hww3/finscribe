import Public.Web.Wiki;

inherit FinScribe.Plugin;

constant name="Weblogs.com PING support";

int _enabled = 1;

mapping query_event_callers()
{
  return (["postSave": sendWeblogPing ]);
}


int sendWeblogPing(string event, object id, object obj)
{
  app->call_out(app->create_thread, 0, send_ping, id, obj);

  return 0;
}


void send_ping(object id, object obj_o)
{
  if(app->get_sys_pref("blog.weblog_ping")->get_value())
  {
    object p = app->get_sys_pref("blog.weblog_ping_urls");
    string urls;
    if(p && (urls=p->get_value())); // do nothing
    else urls = "http://rpc.weblogs.com/RPC2";
    {
      foreach(urls / ",";; string u)
      {

        FinScribe.Blog.weblogs_ping(obj_o["title"],
          (string)Standards.URI("/space/" + obj_o["path"], app->get_sys_pref("site.url")->get_value()),
          String.trim_whites(u));
      }
    }
  }
}

