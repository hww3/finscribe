import Fins;

inherit FinScribe.Plugin;

constant name = "Plugin Support";
constant type = "pluginsupport";

int _enabled = 1;

mapping(string:mixed) query_ipath_callers()
{
  return([ "static": ((program)"static_controller")(app) ]);
}

