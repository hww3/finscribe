import Public.Web.Wiki;
import Fins;
inherit Macros.Macro;

//
// args: 
//
// path - specify the path to insert.
//

string describe()
{
   return "Include the content of another page.";
}

array evaluate(Macros.MacroParameters params)
{
  array res = ({});
  object page;

  params->make_args();

  if(params->args->path)
  {
    page= params->engine->wiki->model->get_fbobject(params->args->path/"/");
  }
  if(!page)
  {
    res = ({sprintf("Page %O not found.", params->args->path)});
    return res;
  }

   mixed id = params->extras->request || ([]);

   // "wiki" is the fins app object.
   params->engine->wiki->view->included_snips[page["path"]] = 1;

   string contents = page->get_object_contents();

   string rv = params->engine->wiki->render(contents, page, id);
  
  return ({rv});
}
