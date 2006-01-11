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

    res+=({"<div class=\"category-feed\">"});
    
    res+=({cat["category"]});
    res+=({"<hr/>\n"});
    ci=0; 
    foreach(cat["objects"];; item)
    {
      res+=({ replace(params->contents, ({"%C", "%L", "%I"}), 
              ({cat["category"], "/space/" + item["path"], 
                item["title"] }) ) 
           });
      ci++;
      if(ci==limit) break;
    }
    res+=({"<a href=\"/exec/category/"});
    res+=({cat["category"]});
    res+=({"\">View all in "});
    res+=({cat["category"]});
    res+=({"...</a>"});
    res+=({"<p/>\n"});
   
   }

    res+=({"</div>"});

  return res;
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

