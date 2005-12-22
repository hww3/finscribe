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

  string datatype = obj["datatype"]["mimetype"];

  switch(datatype)
  {
    case "text/wiki":
      handle_wiki(obj, id, response);
      break;
    default:
      break;
  }
  
  return;
}


private void handle_wiki(object obj, Request id, Response response)
{
  string title = obj["title"];  
  string contents = obj->get_object_contents(id);

      Template.Template t;
        Template.TemplateData dta;
        [t, dta] = view()->prep_template("comments/wikiobjectcomments.phtml");

  app()->set_default_data(id, dta);

  dta->add("obj", obj["path"]);
  dta->add("title", title);
  dta->add("content", app()->engine->render(contents, (["request": id, "obj": obj])));
  dta->add("author", obj["author"]["Name"]);
  dta->add("author_username", obj["author"]["UserName"]);
  dta->add("when", model()->get_when(obj["current_version"]["created"]));
  dta->add("editor", obj["current_version"]["author"]["Name"]);
  dta->add("editor_username", obj["current_version"]["author"]["UserName"]);
  dta->add("version", (string)obj["current_version"]["version"]);
  dta->add("object_is_weblog", id->misc->object_is_weblog);  

  // now, let's get the comments for this page.
  
  array comments = obj["comments"];

  dta->add("comments", comments);
  dta->add("numcomments", sizeof(comments) || "No");
  
  response->set_template(t, dta);
}
