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
  
  if(params->contents)
  {

    if(params->extras->request && !params->extras->request->misc->__have_folder)
    {
      params->extras->request->misc->__have_folder = 1;
      res += ({javascript_predefs});
    }
    else if(!params->extras->request)
    {
      res += ({javascript_predefs});
    }
    res += ({ "<div dojoType=\"dijit.TitlePane\""});
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
<script type=\"text/javascript\">
  dojo.require(\"dijit.TitlePane\");
</script>
";

