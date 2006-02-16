inherit FinScribe.Plugin;

constant name = "HTML content type support";
constant typename = "HTML";

int _enabled = 1;

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
                        "<div style=\"background-color: #ffffff; height: 300px; width: 100%; border-width: 1px; border-style: dashed; border-color: #999999; overflow: auto\"><textarea name=\"contents\" items=\"textGroup;|;listGroup;|;linkGroup;|;colorGroup;|;indentGroup;\" dojoType=\"Editor\">" + 
                        (contents||"Edit your document contents here.") + "</textarea></div>";

}

void add_macro(string n, object m)
{
}
