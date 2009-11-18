//<locale-token project="FinScribe">LOCALE</locale-token>

#define LOCALE(X,Y) Locale.translate(config->app_name, id->get_lang(), X, Y)

import Tools.Logging;

import Fins;
import Fins.Model;
inherit Fins.FinsController;

static void start()
{
  after_filter(Fins.Helpers.Filters.Compress());
}

public void index(Request id, Response response, mixed ... args)
{
  if(!args || !sizeof(args))
  {
     response->redirect(start);
     return;
  }

  object obj = model->get_fbobject(args, id);

  if(!obj)
  {
     response->redirect(app->controller->exec->notfound, args); 
     return;
  }

  if(app->get_sys_pref("blog.pingback_receive")->get_value())
  {
    response->set_header("X-Pingback", app->get_sys_pref("site.url")->get_value() + "/exec/pingback");
  }

  id->misc->current_page = obj["path"];
  id->misc->current_page_object = obj;

  if((int)(app->get_sys_pref("site.track_views")["value"]))
    obj["md"]["views"] ++;

  string datatype = obj["Datatype"]["mimetype"];

  handle(datatype,obj,id,response);

  return;
}

private void handle(string datatype, object obj, Request id, Response response)
{
  object v;

  // support for configuring template on a per-object basis.
  object template;
  object t;

  if(template = obj["template"])
  {
    t = view->get_idview("space/" + template["name"], id);
  }
  else 
    t = view->get_idview("space/wikiobject", id);

  app->set_default_data(id, t);
  if(!obj->is_readable(t->get_data()["user_object"])) 
  {
     response->redirect(app->controller->exec->notreadable, ({obj["path"]})); 
     return;
  }

  if(id->variables->show_version)
  {
    v = find.object_versions((["object": obj, "version": (int)id->variables->show_version]))[0];
    response->flash("msg", LOCALE(330, "Showing archived version"));
  }
  else
  {
    v = obj["current_version"];
  }

  // this is the most confuzzling part of the whole app, I think. 
  // we try to come up with a coherent plan to handle dynamically generated data.

  // we short circuit the short circuit after 600 seconds.   
  if(id->misc->session_variables && ((time() - id->misc->session_variables->logout) >= 600))
       m_delete(id->misc->session_variables, "logout");

  if(id->request_headers["if-modified-since"] && ((
      Protocols.HTTP.Server.http_decode_date(id->request_headers["if-modified-since"])   
        >= v["created"]->unix_time()) ))
  {
    // are we a user? send the data.
    if(id->misc->session_variables && id->misc->session_variables->userid);
    // have we logged out since the last request? send the data.
    else if(id->misc->session_variables && (id->misc->session_variables->logout >= v["created"]->unix_time()));
    // are we a datatype that could be rendered and are more than 600 seconds since the last request, send it again.
    else if((datatype == "text/wiki" || datatype=="text/html") && 
                 (time() - Protocols.HTTP.Server.http_decode_date(id->request_headers["if-modified-since"]) > 600));
    else  
    {
      response->not_modified();
      return;
    }
  }

  array o = find.objects(([ "is_attachment": 1, "parent": obj ]));
  t->add("request", id);
  t->add("obj", obj["path"]);
  t->add("object_version", v);
  t->add("title", obj["title"]);
  t->add("author", obj["author"]["name"]);
  t->add("author_username", obj["author"]["username"]);
  t->add("editor", v["author"]["name"]);
  t->add("editor_username", v["author"]["username"]);
  t->add("numattachments", sizeof(o));
  t->add("attachments", o);
  t->add("object", obj);
  t->add("metadata", obj->get_metadata());

  // now, let's get the comments for this page.
  t->add("numcomments", sizeof(obj["comments"]));
  t->add("numcategories", sizeof(obj["categories"]));
  t->add("categories", (obj["categories"]));
  t->add("category_links", obj["category_links"]);
  t->add("metadata", obj["md"]);
  t->add("numtrackbacks", sizeof(obj["md"]["trackbacks"] || ([])));

  switch(datatype)
  {
    case "text/wiki":
    case "text/html":
      low_handle_wiki(v, t, obj, id, response);
      break;
    case "text/template":
      low_handle_text(v, t, obj, id, response);
      break;
    default:
      low_handle_data(v, obj, id, response);
      return;
      break;
  }

  response->set_view(t);
  response->set_header("Last-Modified", v["created"]->format_http());

}

private void low_handle_wiki(object v, object t, object obj, Request id, Response response)
{
  t->add("content", app->render(v["contents"], obj, id, (int)id->variables->force));
  t->add("object_is_weblog", id->misc->object_is_weblog);

  if(id->misc->object_is_weblog)
  {
    t->add("heads", "<link rel=\"alternate\" type=\"application/rss+xml\" "
                    "title=\"All Entries\" href=\"" +  app->get_sys_pref("site.url")->get_value() 
                    + "/rss/" + obj["path"] + "\"/>");
  }
  else 
  {
    t->add("heads", "");
  }


  t->add("cfcontents", view->render_partial("space/_categoryform", t->get_data()));
}

private void low_handle_text(object v, object t, object obj, Request id, Response response)
{
  response->set_header("Cache-Control", "max-age=3600");
  response->set_header("Expires", (Calendar.Second() + 3600*12)->format_http());

  t->add("content", v["contents"]);
}

private void low_handle_data(object v, object obj, Request id, Response response)
{
  response->set_header("Cache-Control", "max-age=3600");
  response->set_header("Expires", (Calendar.Second() + 3600*12)->format_http());

  response->set_data(v["contents"]);
  response->set_type(obj["Datatype"]["mimetype"]);
}
