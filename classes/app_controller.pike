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

  object obj = predef::get_object(args, id);

  if(!obj)
  {
     response->redirect("/exec/notfound/" + (args*"/")); 
     return;
  }

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
  string title = get_object_title(obj, id);  
  string contents = get_object_contents(obj, id);

  Template.TemplateData dta = Template.TemplateData();
  Template.Template t = view()->get_template(view()->template, "wikiobject.tpl");
 
  if(id->misc->session_variables->userid)
  {
     object user = model()->find_by_id("user", id->misc->session_variables->userid);
     dta->add("username", user["UserName"]);
     dta->add("user", user["Name"]);

  }

  int numattachments; 

  array o = model()->find("object", ([ "is_attachment": 1, 
                          "path": Model.LikeCriteria(obj["path"] + "/%"),
                          "_page": Model.Criteria("NOT LOCATE('/', path, " + (strlen(obj["path"])+2) + ")") ]));
  array datatypes = model()->find("datatype", ([]));
  numattachments = sizeof(o);

  dta->add("obj", obj["path"]);
  dta->add("title", title);
  dta->add("content", app()->engine->render(contents, (["request": id, "obj": obj])));
  dta->add("author", obj["author"]["Name"]);
  dta->add("author_username", obj["author"]["UserName"]);
  dta->add("when", get_when(obj["current_version"]["created"]));
  dta->add("editor", obj["current_version"]["author"]["Name"]);
  dta->add("editor_username", obj["current_version"]["author"]["UserName"]);
  dta->add("version", (string)obj["current_version"]["version"]);
  dta->add("numattachments", numattachments);  
  dta->add("attachments", o);  
  dta->add("datatypes", datatypes);
  dta->add("object_is_weblog", id->misc->object_is_weblog);

  // now, let's get the comments for this page.
  
  dta->add("numcomments", sizeof(obj["comments"]));
  
  response->set_template(t, dta);

}

private void handle_text(object obj, Request id, Response response)
{
  string title = get_object_title(obj, id);  
  string contents = get_object_contents(obj, id);

  Template.TemplateData dta = Template.TemplateData();
  Template.Template t = view()->get_template(view()->template, "wikiobject.tpl");
 
  if(id->misc->session_variables->userid)
  {
     object user = model()->find_by_id("user", id->misc->session_variables->userid);
     dta->add("username", user["UserName"]);
     dta->add("user", user["Name"]);

  }

  int numattachments; 

  array o = model()->find("object", ([ "is_attachment": 1, 
                          "path": Model.LikeCriteria(obj["path"] + "/%"),
                          "_page": Model.Criteria("NOT LOCATE('/', path, " + (strlen(obj["path"])+2) + ")") ]));
  array datatypes = model()->find("datatype", ([]));
  numattachments = sizeof(o);

  dta->add("obj", obj["path"]);
  dta->add("title", title);
  dta->add("content", contents);
  dta->add("author", obj["author"]["Name"]);
  dta->add("author_username", obj["author"]["UserName"]);
  dta->add("when", get_when(obj["current_version"]["created"]));
  dta->add("editor", obj["current_version"]["author"]["Name"]);
  dta->add("editor_username", obj["current_version"]["author"]["UserName"]);
  dta->add("version", (string)obj["current_version"]["version"]);
  dta->add("numattachments", numattachments);  
  dta->add("attachments", o);  
  dta->add("datatypes", datatypes);
  dta->add("object_is_weblog", id->misc->object_is_weblog);

  // now, let's get the comments for this page.
  
  dta->add("numcomments", sizeof(obj["comments"]));
  
  response->set_template(t, dta);

}

private void handle_data(object obj, Request id, Response response)
{
  string contents = get_object_contents(obj, id);
  response->set_data(contents);
  response->set_type(obj["datatype"]["mimetype"]);
}

