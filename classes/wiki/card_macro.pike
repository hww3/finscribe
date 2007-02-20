import Public.Web.Wiki;

inherit Macros.Macro;

constant is_container = 1;

string describe()
{
   return "Present a Tab Container.";
}

array evaluate(Macros.MacroParameters params)
{
  int nohilight;

  if(!params->args) params->make_args();

  array res = ({});
  
  if(params->contents)
  {
    res += ({ "<div dojoType=\"ContentPane\" label=\"" + (params->args->label||"") + "\">" + params->contents + "</div>" });
  }
  else if(params->args->snip)
  {
    object o = params->engine->wiki->model->get_fbobject((params->args->snip)/"/", 0);
    if(!o)
      res += ({ "<div dojoType=\"ContentPane\" label=\"" + (params->args->label||"") + "\">" + "content " + 
                     params->args->snip + " does not exist." + "</div>" });
    else
      res += ({ "<a dojoType=\"LinkPane\" href=\"/exec/get_content/" + params->args->snip + "\">" + o["title"] + "</a>"});
  }
  return res;
}


