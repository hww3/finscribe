import Public.Web.Wiki;

inherit Macros.Macro;

constant is_container = 1;

string describe()
{
   return "Present a Foldup container.";
}

array evaluate(Macros.MacroParameters params)
{
  if(!params->args) params->make_args();

  array res = ({});
  
  object id = params->extras->request;

  if(params->contents)
  {
    if(id && !id->misc->__have_folder)
    {
      id->misc->__have_folder = 1;
      if(id->misc->template_data)
         id->fins_app->view->list_store(
          id->misc->template_data, "jsfooter", javascript_predefs);
    }
    else if(!id)
    {
      res += ({full_javascript_predefs});
    }

    res += ({ "<div dojoType=\"dijit.layout.TitlePane\""});
	if(params->args->title)
      res += ({" title=\"" + params->args->title + "\"" });
	if(params->args->folded)
      res += ({" open=\"" + params->args->open + "\"" });
	res += ({">" });

    res +=  params->engine->macro_rule->full_replace(({params->contents}), params->engine->macros, 
                 params->engine, params->extras);
        res += ({"</div>\n"});
   }
  return res;
}


string javascript_predefs = 
#"
  dojo.require(\"dijit.TitlePane\");
";

string full_javascript_predefs =
"<script type=\"text/javascript\">" + javascript_predefs +
"</script>";


