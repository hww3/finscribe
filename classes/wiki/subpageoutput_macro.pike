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
  // we should get a limit for the number of entries to display.

  subpage = params->extras->request ? params->extras->request->misc->current_page : 0;

  if(!subpage) return ({""});

  return ({params->engine->wiki->view->generate_subpages(subpage, params->extras->request)});
}

int is_cacheable()
{
  return 0;
}
