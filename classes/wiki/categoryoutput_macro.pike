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

  if(!params->args) params->make_args();

	array res = ({});

  if(params->args->limit) limit = (int) params->args->limit;

  m_delete(params->args, "limit");
  
  if(params->args->category) 
  { 
    category = params->args->category;
    m_delete(params->args, "category");
  }

  array a = indices(params->args);

  if(sizeof(a))   
    category = a[-1];

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
    r = Fins.Model.find.categories((["category" : category]));

  return r;
}

