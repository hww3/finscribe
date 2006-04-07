import Tools.Logging;
import Public.Web.Wiki;

inherit FinScribe.Plugin;

constant name="Pingback support";

int _enabled = 1;

mapping query_event_callers()
{
  return (["postSave": sendPingback ]);
}


int sendPingback(string event, object id, object obj)
{
  call_out(send_pingback, 0, id, obj);

  return 0;
}


void send_pingback(object id, object obj_o)
{
            // we use this object for both trackback and pingback processing.
            object u = Standards.URI(app->get_sys_pref("site.url")->get_value());
            u->path = combine_path(u->path, "/space");

           if(app->get_sys_pref("blog.pingback_send")->get_value())
           {

              Log.debug("Checking for pingbacks...");

              array bu = ({});

              app->render(obj_o["current_version"]["contents"], obj_o, id);
              if(id->misc->permalinks)
              {
                foreach(id->misc->permalinks, string url)
                {
                  string l;
                  l = FinScribe.Blog.detect_pingback_url(url);
                  if(l)
                    bu += ({({l, url})});
                }
             }
             foreach(bu;; array pingback_url)
             {
               Log.debug("sending pingback ping for %s", pingback_url[1]);
               FinScribe.Blog.pingback_ping(obj_o, u, pingback_url[1],
                                                      pingback_url[0]);
             }
           }
}

