//! this is a template for a FinScribe plugin

Fins.Application app;

constant name = "";
constant description = "";

void create(Fins.Application _app)
{
	app = _app;
}

int installed();

int enabled();

void start();

void stop();

mapping query_event_callers();


//!
//! @returns a mapping of macroname : Public.Web.Wiki.Macros.Macro objects.
//!
mapping(string:Public.Web.Wiki.Macros.Macro) query_macro_callers();

mapping  query_type_callers();

mapping query_path_callers();

mapping query_ipath_callers();

array query_preferences();
