import Public.Web.Wiki;

inherit Macros.Macro;

constant is_container = 1;

string describe()
{
   return "Format a warning in an attractive manner.";
}

array evaluate(Macros.MacroParameters params)
{
  if(!params->args) params->make_args();

  array res = ({});

  if(params->contents)
  {

    if(params->extras->request && !params->extras->request->misc->__have_warning)
    {
      params->extras->request->misc->__have_warning = 1;
      res += ({javascript_predefs});
    }
    else if(!params->extras->request)
    {
      res += ({javascript_predefs});
    }


    res += ({
#"<table cellpadding='5' width='85%' cellspacing='8px' class='warningMacro' 
border=\"0\" align='center'><colgroup><col width='24'><col></colgroup><tr><td valign='top'><img 
src=\"/static/images/forbidden.gif\" width=\"16\" height=\"16\" 
align=\"absmiddle\" alt=\"\" border=\"0\"></td><td>",

params->contents,

"</td></tr></table>"
});

   }
  return res;
}



string javascript_predefs = 
#"<style type=\"text/css\">
.warningMacro {
background-color:#FFCCCC;
border:1px solid #CC0000;
margin-bottom:5px;
margin-top:5px;
text-align:left;
}
</style>
";
