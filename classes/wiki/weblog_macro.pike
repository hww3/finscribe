import Public.Web.Wiki;
import Fins;
inherit Macros.Macro;

string describe()
{
   return "Produces a weblog";
}

void evaluate(String.Buffer buf, Macros.MacroParameters params)
{
  object root;
  int limit;

// werror("EVALUATE: %O\n", params->extras->obj);

  if(params->extras->obj && !stringp(params->extras->obj))
    root = params->extras->obj;
  else
  {
    array o = params->engine->wiki->model->find("object", (["path": params->extras->obj["path"]]));
    if(sizeof(o))
      root = o[0];
  }

  params->extras->request->misc->object_is_weblog = 1;

  // we should get a limit for the number of entries to display.

  array a = params->parameters / "|";
  if(sizeof(a) && a[0] && strlen(a[0]))
    limit = (int)a[0];
  else limit = 10;

  if(!root)
  {
    buf->add("Unable to render Weblog because the weblog page location could not be determined."); 
    return;
  } 
//werror("root: %O\n", object_program(root));

  array o;

  if(params->extras && params->extras->request && params->extras->request->variables->weblog =="full")
    o = root->get_blog_entries();
  else
    o = root->get_blog_entries(limit);

  foreach(o; int i; object entry)
  {
    buf->add(entry["nice_created"]);
    buf->add("<br/>\n<b>");
    string s = entry["current_version"]["subject"];
    if(!s || !strlen(s)) s = "No Subject";
    buf->add((s));
    buf->add(" <a href=\"/space/");
    buf->add(entry["path"]);
    buf->add("\">");
    buf->add("<img src=\"/static/images/Icon-Permalink.png\" width=\"8\" height=\"9\" alt=\"permalink\" border=\"0\"/>");
    buf->add("</a>");
    buf->add("</b><p/>\n");
    buf->add(params->engine->render(entry["current_version"]["contents"], (["request": params->extras->request, "obj": entry])));
    buf->add("<p/>");

    if(sizeof(entry["categories"]))
    {
       buf->add("Posted in ");
       foreach(entry["categories"];; object c)
       {
         buf->add("<a href=\"/exec/category/");
         buf->add(c["category"]);
         buf->add("\">");
         buf->add(c["category"]);
         buf->add("</a> ");
       }
    buf->add("<p/>");
    }


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

    buf->add(" | <a href=\"/rss/");
    buf->add(entry["path"]);
    buf->add("?type=comments\">RSS Feed</a>");

    buf->add(" | <a href=\"/exec/display_trackbacks/");
    buf->add(entry["path"]);
    buf->add("\">");
werror("TB: %O, %O\n", entry["path"], entry["md"]["trackbacks"]);
    buf->add((string)sizeof(entry["md"]["trackbacks"] || ({})));
    buf->add(" TrackBacks</a> | ");

    buf->add((string)entry["md"]["views"]);
    buf->add(" reads");

    buf->add("<p/>\n");
    buf->add("<p/>\n");

  }

  if(params->extras && params->extras->request && params->extras->request->variables->weblog =="full")
    buf->add("<a href=\"?weblog=recent\">Recent Entries...</a> | ");
  else
    buf->add("<a href=\"?weblog=full\">More Entries...</a> | ");
  buf->add("<a href=\"/rss/");
  buf->add(root["path"]);
  buf->add("\">RSS Feed</a>");
}
