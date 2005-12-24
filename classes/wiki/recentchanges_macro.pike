import Public.Web.Wiki;

inherit Macros.Macro;

string describe()
{
   return "Recently Changed Objects";
}
array evaluate(Macros.MacroParameters params)
{

  if(params->engine->macro_recent_changes && functionp(params->engine->macro_recent_changes))
  {
    return ({params->engine->macro_recent_changes()});
  }  

}
