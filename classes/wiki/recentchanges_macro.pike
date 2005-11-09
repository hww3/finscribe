import Public.Web.Wiki;

inherit Macros.Macro;

string describe()
{
   return "Recently Changed Objects";
}
void evaluate(String.Buffer buf, Macros.MacroParameters params)
{

  if(params->engine->macro_recent_changes && functionp(params->engine->macro_recent_changes))
  {
    buf->add(params->engine->macro_recent_changes());
  }  

}
