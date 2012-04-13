import Public.Web.Wiki;

inherit Macros.Macro;

string describe()
{
   return "inserts a break command for generating teasers in weblog entries.";
}

array evaluate(Macros.MacroParameters params)
{
  return ({"<!--break-->"});
}



