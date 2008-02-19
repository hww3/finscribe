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

  if((int)(app->get_sys_pref("site.track_views")["Value"]))
    obj["md"]["views"] ++;

  string datatype = obj["datatype"]["mimetype"];
  switch(datatype)
  {
    case "text/wiki":
      handle_wiki(obj, id, response);
      break;
    case "text/html":
      handle_wiki(obj, id, response);
      break;
    case "text/template":
      handle_text(obj, id, response);
      break;
    default:
      handle_data(obj, id, response);
      break;
  }

  return;
}

private void handle_wiki(object obj, Request id, Response response){

  object t = view->get_idview("space/wikiobject");

  app->set_default_data(id, t);

  if(!obj->is_readable(t->get_data()["user_object"])) 
  {
     response->redirect(app->controller->exec->notreadable, obj["path"]); 
     return;
  }
 
  int numattachments; 

  array o = find.objects(([ "is_attachment": 1, "parent": obj ]));
  object v;
  if(id->variables->show_version)
  {
    v = find.object_versions((["object": obj, "version": (int)id->variables->show_version]))[0];
    response->flash("msg", LOCALE(1, "Showing archived version"));
  }
  else
  {
    v = obj["current_version"];
  }

  // we short circuit the short circuit after 600 seconds.   
  if(id->misc->session_variables && ((time() - id->misc->session_variables->logout) >= 600))
       m_delete(id->misc->session_variables, "logout");

  if(id->request_headers["if-modified-since"] && ((
      Protocols.HTTP.Server.http_decode_date(id->request_headers["if-modified-since"])   
        >= v["created"]->unix_time()) ))
  {
    // we cop out on the more complex boolean expression above :)
    if(id->misc->session_variables && id->misc->session_variables->userid);
    else if(id->misc->session_variables && (id->misc->session_variables->logout >= v["created"]->unix_time()));
    else if(time() - Protocols.HTTP.Server.http_decode_date(id->request_headers["if-modified-since"]) > 600);
    else  
    {
      response->not_modified();
      return;
    }
  }

  string contents = v["contents"];
  numattachments = sizeof(o);

  t->add("obj", obj["path"]);
  t->add("title", obj["title"]);
  t->add("content", app->render(contents, obj, id, id->variables->refresh));

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

  t->add("author", obj["author"]["Name"]);
  t->add("author_username", obj["author"]["UserName"]);
  t->add("when", model->get_when(v["created"]));
  t->add("editor", v["author"]["Name"]);
  t->add("editor_username", v["author"]["UserName"]);
  t->add("version", (string)v["version"]);
  t->add("numattachments", numattachments);  
  t->add("attachments", o);  
  t->add("object_is_weblog", id->misc->object_is_weblog);
  t->add("object", obj);
  t->add("metadata", obj->get_metadata());

  // now, let's get the comments for this page.
  t->add("numcomments", sizeof(obj["comments"]));
  t->add("numcategories", sizeof(obj["categories"]));
  t->add("categories", (obj["categories"]));
  t->add("category_links", obj["category_links"]);
  t->add("metadata", obj["md"]); 
  t->add("numtrackbacks", sizeof(obj["md"]["trackbacks"] || ([])));

  t->add("cfcontents", view->render_partial("space/_categoryform", t->get_data()));

  response->set_view(t);

  response->set_header("Last-Modified", v["created"]->format_http());
}

private void handle_text(object obj, Request id, Response response)
{
  object t = view->get_idview("space/wikiobject");

  app->set_default_data(id, t);

  if(!obj->is_readable(t->get_data()["user_object"])) 
  {
     response->redirect(app->controller->exec->notreadable, obj["path"]); 
     return;
  }
 
  int numattachments; 

  object v;

  if(id->variables->show_version)
  {
    v = find.object_versions((["object": obj, "version": (int)id->variables->show_version]))[0];
    response->flash("msg", LOCALE(1, "Showing archived version"));
  }
  else
  {
    v = obj["current_version"];
  }

  if(id->request_headers["if-modified-since"] &&
      Protocols.HTTP.Server.http_decode_date(id->request_headers["if-modified-since"])   
        >= v["created"]->unix_time())
  {
    // we cop out on the more complex boolean expression above :)
    if(id->misc->session_variables && id->misc->session_variables->userid);
    else  
    {
      response->not_modified();
      return;
    }
  }

  response->set_header("Cache-Control", "max-age=3600");
  response->set_header("Last-Modified", v["created"]->format_http());
  response->set_header("Expires", (Calendar.Second() + 3600*12)->format_http());

  string contents = v["contents"];

  array o = find.object_versions(([ "is_attachment": 1, "parent": obj ]));
  array datatypes = model->get_datatypes();
  numattachments = sizeof(o);

  t->add("obj", obj["path"]);
  t->add("title", obj["title"]);
  t->add("content", contents);
  t->add("author", obj["author"]["Name"]);
  t->add("author_username", obj["author"]["UserName"]);
  t->add("when", model->get_when(v["created"]));
  t->add("editor", v["author"]["Name"]);
  t->add("editor_username", v["author"]["UserName"]);
  t->add("version", (string)v["version"]);
  t->add("numattachments", numattachments);  
  t->add("attachments", o);  
  t->add("datatypes", datatypes);
  t->add("object_is_weblog", id->misc->object_is_weblog);
  t->add("metadata", obj["md"]);  

  // now, let's get the comments for this page.
  
  t->add("numcomments", sizeof(obj["comments"]));
  t->add("numcategories", sizeof(obj["categories"]));
  response->set_view(t);

}

private void handle_data(object obj, Request id, Response response)
{
  object v;

  if(!obj->is_readable(app->get_current_user(id))) 
  {
     response->redirect(app->controller->exec->notreadable, obj["path"]); 
     return;
  }

  if(id->variables->show_version)
  {
    v = find.object_versions((["object": obj, "version": (int)id->variables->show_version]))[0];
  }
  else
  {
    v = obj["current_version"];
  }

  if(id->request_headers["if-modified-since"] &&
      Protocols.HTTP.Server.http_decode_date(id->request_headers["if-modified-since"])   
        >= v["created"]->unix_time())
  {
    // we cop out on the more complex boolean expression above :)
    if(id->misc->session_variables && id->misc->session_variables->userid);
    else  
    {
      response->not_modified();
      return;
    }
  }
  
  response->set_header("Cache-Control", "max-age=3600");
  response->set_header("Last-Modified", v["created"]->format_http());
  response->set_header("Expires", (Calendar.Second() + 3600*12)->format_http());

  string contents = v["contents"];

  response->set_data(contents);
  response->set_type(obj["datatype"]["mimetype"]);
}

