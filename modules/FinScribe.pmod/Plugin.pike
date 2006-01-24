//! this is a template for a FinScribe plugin

Fins.Application app;

constant name = "";
constant description = "";

void create(Fins.Application _app)
{
	app = _app;
}

int installed()
{
	return 0;
}

int enabled()
{
	return 0;
}

void start()
{
	
}

void stop()
{
	
}

mapping query_event_callers()
{
	return ([]);
}


//!
//! @returns a mapping of macroname : Public.Web.Wiki.Macros.Macro objects.
//!
mapping(string:Public.Web.Wiki.Macros.Macro) query_macro_callers()
{
	return ([]);
}

mapping  query_type_callers()
{
	return ([]);
}

mapping query_path_callers()
{
	return ([]);
}

array query_preferences()
{
	return ({});
}
