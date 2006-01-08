//<locale-token project="finscribe">LOCALE</locale-token>

#define LOCALE(X,Y) Locale.translate(app()->config->app_name, id->get_lang(), X, Y)

import Fins;
import Fins.Model;
inherit Fins.FinsController;


public void index(Request id, Response response, mixed ... args)
{

  if(!args || !sizeof(args))
  {
     response->redirect("start");
     return;
  }

  object obj = model()->get_fbobject(args, id);

  if(!obj)
  {
     response->redirect("/exec/notfound/" + (args*"/")); 
     return;
  }

  if(app()->config["site"]["track_views"])
    obj["md"]["views"] ++;

  string datatype = obj["datatype"]["mimetype"];

  switch(datatype)
  {
    case "text/wiki":
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

private void handle_wiki(object obj, Request id, Response response)
{
  string title = obj["title"];  

        Template.Template t;
        Template.TemplateData dta;
        [t, dta] = view()->prep_template("space/wikiobject.phtml");

  app()->set_default_data(id, dta);
 
  int numattachments; 

  array o = model()->find("object", ([ "is_attachment": 1, "parent": obj ]));
  object v;
  if(id->variables->show_version)
  {
    v = model()->find("object_version", (["object": obj, "version": (int)id->variables->show_version]))[0];
    response->flash("msg", LOCALE(1, "Showing archived version"));
  }
  else
  {
    v = obj["current_version"];
  }

  string contents = v["contents"];
  array datatypes = model()->get_datatypes();
  array categories = model()->get_categories();
  numattachments = sizeof(o);

  dta->add("obj", obj["path"]);
  dta->add("title", title);
  dta->add("content", app()->engine->render(contents, (["request": id, "obj": obj])));
  dta->add("author", obj["author"]["Name"]);
  dta->add("author_username", obj["author"]["UserName"]);
  dta->add("when", model()->get_when(v["created"]));
  dta->add("editor", v["author"]["Name"]);
  dta->add("editor_username", v["author"]["UserName"]);
  dta->add("version", (string)v["version"]);
  dta->add("numattachments", numattachments);  
  dta->add("attachments", o);  
  dta->add("datatypes", datatypes);
  dta->add("existing-categories", categories);
  dta->add("object_is_weblog", id->misc->object_is_weblog);
  dta->add("object", obj);
  dta->add("metadata", obj->get_metadata());

  dta->add("islocked", obj["md"]["locked"]);
  dta->add("iseditable", obj->is_editable(dta->get_data()["user_object"]));
  dta->add("islockable", obj->is_lockable(dta->get_data()["user_object"]));
  
  // now, let's get the comments for this page.
  dta->add("numcomments", sizeof(obj["comments"]));
  dta->add("numcategories", sizeof(obj["categories"]));
  dta->add("categories", (obj["categories"]));
  dta->add("metadata", obj["md"]); 
  dta->add("numtrackbacks", sizeof(obj["md"]["trackbacks"] || ([])));
  response->set_template(t, dta);

}

private void handle_text(object obj, Request id, Response response)
{
  string title = obj["title"];  

        Template.Template t;
        Template.TemplateData dta;
        [t, dta] = view()->prep_template("space/wikiobject.phtml");

  app()->set_default_data(id, dta);
 
  int numattachments; 

  object v;

  if(id->variables->show_version)
  {
    v = model()->find("object_version", (["object": obj, "version": (int)id->variables->show_version]))[0];
    response->flash("msg", LOCALE(1, "Showing archived version"));
  }
  else
  {
    v = obj["current_version"];
  }

  if(id->request_headers["if-modified-since"] &&
      Protocols.HTTP.Server.http_decode_date(id->request_headers["if-modified-since"])   
        > v["created"]->unix_time())
  {
    response->not_modified();
    return;
  }
  
  response->set_header("Cache-Control", "max-age=3600");
  response->set_header("Last-Modified", v["created"]->format_http());

  string contents = v["contents"];

  array o = model()->find("object", ([ "is_attachment": 1, "parent": obj ]));
  array datatypes = model()->get_datatypes();
  numattachments = sizeof(o);

  dta->add("obj", obj["path"]);
  dta->add("title", title);
  dta->add("content", contents);
  dta->add("author", obj["author"]["Name"]);
  dta->add("author_username", obj["author"]["UserName"]);
  dta->add("when", model()->get_when(v["created"]));
  dta->add("editor", v["author"]["Name"]);
  dta->add("editor_username", v["author"]["UserName"]);
  dta->add("version", (string)v["version"]);
  dta->add("numattachments", numattachments);  
  dta->add("attachments", o);  
  dta->add("datatypes", datatypes);
  dta->add("object_is_weblog", id->misc->object_is_weblog);
  dta->add("metadata", obj["md"]);  

  // now, let's get the comments for this page.
  
  dta->add("numcomments", sizeof(obj["comments"]));
  dta->add("numcategories", sizeof(obj["categories"]));
  response->set_template(t, dta);

}

private void handle_data(object obj, Request id, Response response)
{
  object v;

  if(id->variables->show_version)
  {
    v = model()->find("object_version", (["object": obj, "version": (int)id->variables->show_version]))[0];
  }
  else
  {
    v = obj["current_version"];
  }

  if(id->request_headers["if-modified-since"] &&
      Protocols.HTTP.Server.http_decode_date(id->request_headers["if-modified-since"])   
        > v["created"]->unix_time())
  {
    response->not_modified();
    return;
  }
  
  response->set_header("Cache-Control", "max-age=3600");
  response->set_header("Last-Modified", v["created"]->format_http());

  string contents = v["contents"];

  response->set_data(contents);
  response->set_type(obj["datatype"]["mimetype"]);
}

