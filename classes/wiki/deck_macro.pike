import Public.Web.Wiki;

inherit Macros.Macro;

constant is_container = 1;

string describe()
{
   return "Present a Tab Container.";
}

array evaluate(Macros.MacroParameters params)
{
  if(!params->args) params->make_args();

  array res = ({});
//werror("%O\n", params->extras);  
  object id = params->extras->request;

  if(params->contents)
  {
    if(id && !id->misc->__have_deck)
    {      
      id->misc->__have_deck = 1;
      if(id->misc->template_data)
         id->fins_app->view->list_store(
          id->misc->template_data, "jsfooter", javascript_predefs);
    }
    else if(!id)
    {
      res += ({full_javascript_predefs});
    }
    res += ({ "<div style=\"width:70%; height:400px;\"><div dojoType=\"dijit.layout.TabContainer\" style=\"width:100%; height:100%;\">" });

    res +=  params->engine->macro_rule->full_replace(({params->contents}), params->engine->macros, 
                 params->engine, params->extras);
        res += ({"</div></div>\n"});
   }
  return res;
}

string javascript_predefs = 
#"
	dojo.require(\"dijit.layout.TabContainer\");
	dojo.require(\"dijit.layout.ContentPane\");
";

string full_javascript_predefs = 
"<script type=\"text/javascript\">" + javascript_predefs + 
"</script>";


