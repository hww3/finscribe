//<locale-token project="FinScribe">LOCALE</locale-token>

#define LOCALE(X,Y) Locale.translate(config->app_name, id->get_lang(), X, Y)

import Tools.Logging;

import Fins;
import Fins.Model;
inherit Fins.FinsController;

static void start()
{
  after_filter(Fins.Helpers.Filters.Compress());
  /*
    after_filter(lambda(object id, object response, mixed ... args) {  
                if(response->get_data())
                  response->set_data(replace(response->get_data(), ({"<!", "!"}), ({"<!", ", bork bork bork!"}))); return 1;
              } );
  */
}

public void index(Request id, Response response, mixed ... args)
{
  if(!args || !sizeof(args))
  {
     response->redirect("start");
     return;
  }


  object obj = model->get_fbobject(args, id);

  if(!obj)
  {
     response->redirect("/exec/notfound/" + (args*"/")); 
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

  breakpoint("test", id, response);
  
  return;
}

private void handle_wiki(object obj, Request id, Response response){
  string title = obj["title"];  

  object t = view->get_idview("space/wikiobject");

  app->set_default_data(id, t);
 
  int numattachments; 

  array o = model->find("object", ([ "is_attachment": 1, "parent": obj ]));
  object v;
  if(id->variables->show_version)
  {
    v = model->find("object_version", (["object": obj, "version": (int)id->variables->show_version]))[0];
    response->flash("msg", LOCALE(1, "Showing archived version"));
  }
  else
  {
    v = obj["current_version"];
  }

  string contents = v["contents"];
  numattachments = sizeof(o);

  t->add("obj", obj["path"]);
  t->add("title", title);
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


/*
  t->add("islocked", obj["md"]["locked"]);
  t->add("iseditable", obj->is_editable(t->get_data()["user_object"]));
  t->add("islockable", obj->is_lockable(t->get_data()["user_object"]));
  */

  // now, let's get the comments for this page.
  t->add("numcomments", sizeof(obj["comments"]));
  t->add("numcategories", sizeof(obj["categories"]));
  t->add("categories", (obj["categories"]));
  t->add("category_links", obj["category_links"]);
  t->add("metadata", obj["md"]); 
  t->add("numtrackbacks", sizeof(obj["md"]["trackbacks"] || ([])));

  t->add("cfcontents", view->render_partial("space/_categoryform", t->get_data()));

  response->set_view(t);

  response->set_header("Cache-Control", "max-age=1200");
  response->set_header("Expires", (Calendar.Second() + 1200)->format_http());


}

private void handle_text(object obj, Request id, Response response)
{
  string title = obj["title"];  

  object t = view->get_idview("space/wikiobject");

  app->set_default_data(id, t);
 
  int numattachments; 

  object v;

  if(id->variables->show_version)
  {
    v = model->find("object_version", (["object": obj, "version": (int)id->variables->show_version]))[0];
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
    response->not_modified();
    return;
  }

  response->set_header("Cache-Control", "max-age=3600");
  response->set_header("Last-Modified", v["created"]->format_http());
  response->set_header("Expires", (Calendar.Second() + 3600*12)->format_http());

  string contents = v["contents"];

  array o = model->find("object", ([ "is_attachment": 1, "parent": obj ]));
  array datatypes = model->get_datatypes();
  numattachments = sizeof(o);

  t->add("obj", obj["path"]);
  t->add("title", title);
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

  if(id->variables->show_version)
  {
    v = model->find("object_version", (["object": obj, "version": (int)id->variables->show_version]))[0];
  }
  else
  {
    v = obj["current_version"];
  }

  if(id->request_headers["if-modified-since"] &&
      Protocols.HTTP.Server.http_decode_date(id->request_headers["if-modified-since"])   
        >= v["created"]->unix_time())
  {
    response->not_modified();
    return;
  }
  
  response->set_header("Cache-Control", "max-age=3600");
  response->set_header("Last-Modified", v["created"]->format_http());
  response->set_header("Expires", (Calendar.Second() + 3600*12)->format_http());

  string contents = v["contents"];

  response->set_data(contents);
  response->set_type(obj["datatype"]["mimetype"]);
}

