import Public.Web.Wiki;

inherit Macros.Macro;

constant is_container = 1;

string describe()
{
   return "Present a Foldup container.";
}

array evaluate(Macros.MacroParameters params)
{
  int nohilight;

  if(!params->args) params->make_args();

  array res = ({});
  
  if(params->contents)
  {

    if(params->extras->request && !params->extras->request->misc->__have_folder)
    {
      params->extras->request->misc->__have_folder = 1;
      res += ({javascript_predefs});
    }
    else
    {
      res += ({javascript_predefs});
    }
    res += ({ "<div dojoType=\"fins:Folder\">" });

    res +=  params->engine->macro_rule->full_replace(({params->contents}), params->engine->macros, 
                 params->engine, params->extras);
        res += ({"</div>\n"});
   }
  return res;
}


string javascript_predefs = 
#"
<script type=\"text/javascript\">
	dojo.require(\"fins.widget.Folder\");
</script>
";

