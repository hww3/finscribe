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
