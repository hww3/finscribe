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

  object obj = model->get_fbobject(args, id);

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

  object t = view->get_view("comments/wikiobjectcomments");

  app->set_default_data(id, t);

  t->add("obj", obj["path"]);
  t->add("title", title);
  t->add("content", app->render(contents, obj, id));
  t->add("author", obj["author"]["Name"]);
  t->add("author_username", obj["author"]["UserName"]);
  t->add("when", model->get_when(obj["current_version"]["created"]));
  t->add("editor", obj["current_version"]["author"]["Name"]);
  t->add("editor_username", obj["current_version"]["author"]["UserName"]);
  t->add("version", (string)obj["current_version"]["version"]);
  t->add("object_is_weblog", id->misc->object_is_weblog);  

  // now, let's get the comments for this page.
  
  array comments = obj["comments"];

  t->add("comments", comments);
  t->add("numcomments", sizeof(comments) || "No");
  
  response->set_view(t);
}
