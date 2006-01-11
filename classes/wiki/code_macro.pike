import Public.Web.Wiki;

inherit Macros.Macro;

string describe()
{
   return "Format code in an attractive manner.";
}

array evaluate(Macros.MacroParameters params)
{
        array res = ({});
   res += ({"<div class=\"code\"><pre>"});
   if(params->contents)
   {
     res += ({
                FontLock.Pike.highlight("", ([]), params->contents)
//replace(params->contents, ({"&", "<", ">", "[", "\\"}), ({"&amp;", "&lt;", "&gt;", "&#91;", "&#92;"}))
});
        res += ({"</pre></div>\n"});
   }
  return res;
}



