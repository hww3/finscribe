inherit FinScribe.Plugin;

constant name = "HTML content type support";

void start()
{
	werror("starting html");
}

mapping query_macro_callers()
{
  return ([]);
}

mapping query_type_callers()
{
  return (["text/html" : this]);
}


string get_widget(string contents)
{
     return "<script type=\"text/javascript\">dojo.require(\"dojo.widget.Editor\"); </script> "
                        "<textarea rows=\"10\" cols=\"60\" name=\"contents\" dojoType=\"Editor\">" + 
                        contents + "</textarea>";

}

void add_macro(string n, object m)
{
}
