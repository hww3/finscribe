import Public.Web.Wiki;
import Fins;
inherit Macros.Macro;

string describe()
{
   return "Handles images";
}

void evaluate(String.Buffer buf, Macros.MacroParameters params)
{
  string root;

  if(params->extras->obj && objectp(params->extras->obj))
    root = params->extras->obj["path"];
  else
    root = params->extras->obj;


  params->extras->request->misc->object_is_weblog = 1;

  if(!root)
  {
    buf->add("Unable to render Weblog because the weblog page location could not be determined."); 
    return;
  } 

  array o = get_blog_entries(root);

  foreach(o; int i; object entry)
  {
    buf->add(entry["nice_created"]);
    buf->add("<br/>\n<b>");
    buf->add((entry["current_version"]["subject"]||"No Subject"));
    buf->add(" <a href=\"/space/");
    buf->add(entry["path"]);
    buf->add("\">");
    buf->add("<img src=\"/static/images/Icon-Permalink.png\" width=\"8\" height=\"9\" alt=\"permalink\" border=\"0\"/>");
    buf->add("</a>");
    buf->add("</b><p/>\n");
    buf->add(params->engine->render(entry["current_version"]["contents"], (["request": params->extras->request, "obj": entry])));
    buf->add("<p/>");

    if(sizeof(entry["comments"]))
    {
      buf->add("<a href=\"/comments/");
      buf->add(entry["path"]);
      buf->add("\">");
      buf->add((string)sizeof(entry["comments"]));
      buf->add(" Comments</a>\n");
    }
    else
    {
      buf->add("No Comments");
    }
    buf->add(" | <a href=\"/exec/comments/");
    buf->add(entry["path"]);
    buf->add("\">Post Comment</a>");
    buf->add("<p/>\n");
    buf->add("<p/>\n");

  }

}
