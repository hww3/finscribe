import Public.Web.Wiki;

inherit Macros.Macro;

constant is_container = 1;

string describe()
{
   return "Format code in an attractive manner.";
}

array evaluate(Macros.MacroParameters params)
{
  int nohilight;

  if(!params->args) params->make_args();

  if(params->args->nohilight)
    nohilight = 1;
        
  array res = ({});
  res += ({"<div class=\"code\"><pre>"});

  if(params->contents)
  {
    res += ({
                (!nohilight?FontLock.Pike.highlight("", ([]), params->contents):params->contents)
//replace(params->contents, ({"&", "<", ">", "[", "\\"}), ({"&amp;", "&lt;", "&gt;", "&#91;", "&#92;"}))
});
        res += ({"</pre></div>\n"});
   }
  return res;
}



