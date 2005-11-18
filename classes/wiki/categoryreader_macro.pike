import Public.Web.Wiki;
import Fins;
inherit Macros.Macro;

string describe()
{
   return "Displays a list of items in a category";
}

void evaluate(String.Buffer buf, Macros.MacroParameters params)
{
  string category;
  int limit;

  // we should get a limit for the number of entries to display.


  array a = params->parameters / "|";

  if(!sizeof(a) || !strlen(a[0])); // nothing
  else category = a[0];

  if(sizeof(a)>1 && a[1] && strlen(a[1]))
    limit = (int)a[1];
  else limit = 10;

  mixed r = params->engine->wiki->cache->get("__CATEGORYdata-" + category);

  if(!r)
  {
    r = category_fetch(category, params);
    if(r)
      params->engine->wiki->cache->set("__CATEGORYdata-" + category, r, 
1800);
  }

  if(!r) 
  {
    buf->add("RSS: invalid RSS document\n");
    return;
  }

  int ci=0;

  foreach(r;; mixed cat)
  {
    object item;

    buf->add("<div class=\"category-feed\">");
    buf->add(cat["category"]);
    buf->add("<hr/>\n<ul>\n");
    ci=0; 
werror("cat: %O\n", cat);
    foreach(cat["objects"];; item)
    {
      buf->add("<li/>\n");
      buf->add("<a href=\"/space/");
      buf->add(item["path"]);
      buf->add("\">");
      buf->add(params->engine->wiki->model->get_object_title(item));
      buf->add("</a>");
      buf->add("\n");
      ci++;
      if(ci==limit) break;
    }
    buf->add("</ul>\n");
    buf->add("<a href=\"/exec/category/");
    buf->add(cat["category"]);
    buf->add("\">View all in ");
    buf->add(cat["category"]);
    buf->add("...</a>");
    buf->add("<p/>\n");
   
   }

    buf->add("</div>");

  return;
}


mixed category_fetch(string category, object params)
{
  array r;

  werror("category-reader: getting " + category + "\n");


  if(!category)
    r = params->engine->wiki->model->get_categories();
  else
    r = params->engine->wiki->model->find("category", (["category" : category]));

  return r;
}

