//! this is a template for a FinScribe plugin

Fins.Application app;

constant name = "";
constant description = "";
string module_dir = "";

int _enabled = 0;

void create(Fins.Application _app)
{
	app = _app;
}

int installed();

int enabled()
{
  mixed m;

  m = app->new_pref("plugin." + name + ".enabled", _enabled, FinScribe.BOOLEAN);
  return m->get_value();
}


void start();

void stop();

mixed get_preference(string pref)
{
  return app->get_sys_pref("plugin." + name + "." + pref);
}

mapping query_event_callers();


//!
//! @returns a mapping of macroname : Public.Web.Wiki.Macros.Macro objects.
//!
mapping(string:Public.Web.Wiki.Macros.Macro) query_macro_callers();

mapping query_type_callers();

mapping query_path_callers();

mapping query_ipath_callers();

mapping(string:mapping) query_preferences();
