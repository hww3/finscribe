import Public.Web.Wiki;

inherit Macros.Macro;

string describe()
{
   return "Format code in an attractive manner.";
}

array evaluate(Macros.MacroParameters params)
{
  int nohilight;

  array a = params->parameters/"|";
  foreach(a;;string p)
  {
    if(p=="nohilight") nohilight=1;
  }
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



