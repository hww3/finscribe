import Public.Web.Wiki;

inherit Macros.Macro;

constant is_container = 1;

string describe()
{
   return "Present a Tab Container. args: label/title, snip";
}

array evaluate(Macros.MacroParameters params)
{
  if(!params->args) params->make_args();

  array res = ({});
  
  if(params->contents)
  {
    res += ({ "<div dojoType=\"dijit.layout.ContentPane\" title=\"" + (params->args->label||" Card ") + "\">" + params->contents + "</div>" });
  }
  else if(params->args->snip)
  {
    object o = params->engine->wiki->model->get_fbobject((params->args->snip)/"/", 0);
    if(!o)
      res += ({ "<div dojoType=\"dijit.layout.ContentPane\" label=\"" + 
(params->args->label||params->args->title||" ") + "\">" + "content " + 
                     params->args->snip + " does not exist." + "</div>" });
    else
      res += ({ "<a dojoType=\"dijit.layout.ContentPane\" href=\"/exec/get_content/" 
+ params->args->snip + "\">" + o["title"] + "</a>"});
  }
  return res;
}


