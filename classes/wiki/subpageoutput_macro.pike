import Public.Web.Wiki;
import Fins;
inherit Macros.Macro;

string describe()
{
   return "Displays a list of items that are subpages of the current page";
}

array evaluate(Macros.MacroParameters params)
{
  string subpage;
  int limit;
  // we should get a limit for the number of entries to display.


  array res = ({"whee"});
werror(">>>\n>>>subpage: %O\n>>>\n", params->extras);

  subpage = params->extras->request ? params->extras->request->misc->current_page : 0;
werror("subpage: %O\n", subpage);

  if(!subpage) return res;

  mixed r = params->engine->wiki->cache->get("__SUBPAGESdata-" + subpage);

  if(!r)
  {
    r = subpage_fetch(subpage, params);
    if(r)
      params->engine->wiki->cache->set("__SUBPAGESdata-" + subpage, r, 1800);
  }

werror("subpageoutput macro!\n");
  int ci=0;

  res = ({ params->engine->wiki->view->render_partial("space/_objectlist", (["objects": r])) });

  return res;
}

int is_cacheable()
{
  return 0;
}

mixed subpage_fetch(string subpage, object params)
{
  array r;

  werror("subpage-output: getting " + subpage + "\n");


  r = params->engine->wiki->model->find("object", (["path" : 
           Fins.Model.AndCriteria(({
              Fins.Model.LikeCriteria(subpage + "/%")
              , Fins.Model.NotCriteria(Fins.Model.LikeCriteria(subpage + "/%/%"))
      }))
      , "is_attachment": 0]));

  return r;
}

