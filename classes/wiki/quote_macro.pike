import Public.Web.Wiki;
inherit Macros.Macro;

constant is_container = 1;

string describe()
{
   return "Format quote in an attractive manner.";
}

array evaluate(Macros.MacroParameters params)
{
  if(!params->args) params->make_args();
        
  array res = ({});
  res += ({"<blockquote>"});

  if(params->contents)
  {
    res += ({params->contents});
  }

  res += ({"</blockquote>\n"});
  return res;
}


