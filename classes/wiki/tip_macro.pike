import Public.Web.Wiki;

inherit Macros.Macro;

constant is_container = 1;

string describe()
{
   return "Format a tip in an attractive manner.";
}

array evaluate(Macros.MacroParameters params)
{
  int nohilight;

  if(!params->args) params->make_args();

  array res = ({});

  if(params->contents)
  {

    if(params->extras->request && !params->extras->request->misc->__have_tip)
    {
      params->extras->request->misc->__have_tip = 1;
      res += ({javascript_predefs});
    }
    else if(!params->extras->request)
    {
      res += ({javascript_predefs});
    }


    res += ({
#"<table cellpadding='5' width='85%' cellspacing='8px' class='tipMacro' 
border=\"0\" align='center'><colgroup><col width='24'><col></colgroup><tr><td valign='top'><img 
src=\"/static/images/check.gif\" width=\"16\" height=\"16\" 
align=\"absmiddle\" alt=\"\" border=\"0\"></td><td>",

params->contents,

"</td></tr></table>"
});

   }
  return res;
}



string javascript_predefs = 
#"<style type=\"text/css\">
.tipMacro {
background-color:#DDFFDD;
border:1px solid #009900;
margin-bottom:5px;
margin-top:5px;
text-align:left;
}
</style>
";
