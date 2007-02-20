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

    if(params->extras->request && !params->extras->request->misc->__have_deck)
    {
      params->extras->request->misc->__have_deck = 1;
      res += ({javascript_predefs});
    }
    else
    {
      res += ({javascript_predefs});
    }
    res += ({ "<div dojoType=\"LayoutContainer\"><div dojoType=\"TabContainer\" doLayout=\"false\">" });

    res +=  params->engine->macro_rule->full_replace(({params->contents}), params->engine->macros, 
                 params->engine, params->extras);
        res += ({"</div></div>\n"});
   }
  return res;
}


string javascript_predefs = 
#"
<script type=\"text/javascript\">
	dojo.require(\"dojo.widget.TabContainer\");
	dojo.require(\"dojo.widget.LinkPane\");
	dojo.require(\"dojo.widget.ContentPane\");
	dojo.require(\"dojo.widget.LayoutContainer\");
</script>
";

