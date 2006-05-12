import Public.Web.Wiki;
import Fins;
inherit Macros.Macro;

string describe()
{
   return "Displays a list of items in a category";
}

array evaluate(Macros.MacroParameters params)
{
  string category;
  int limit;

  // we should get a limit for the number of entries to display.


  array a = params->parameters / "|";
	array res = ({});
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
    return ({"RSS: invalid RSS document\n"});
  }

  int ci=0;

  foreach(r;; mixed cat)
  {
    object item;

    res+=({"<h3><a href=\"/exec/category/" + cat["category"] + "\">" + cat["category"] + "</a></h3>"});
    ci=0; 
    foreach(cat["objects"];; item)
    {
      res+=({ "<li><a href=\"/space/" + item["path"] + "\">" + item["title"] + "</a>" });
      ci++;
      if(ci==limit) break;
    }
   }

  return res;
}


mixed category_fetch(string category, object params)
{
  array r;

  if(!category)
    r = params->engine->wiki->model->get_categories();
  else
    r = params->engine->wiki->model->find("category", (["category" : category]));

  return r;
}

