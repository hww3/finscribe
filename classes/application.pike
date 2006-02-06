import Fins;
inherit Fins.Application : app;
inherit Fins.Helpers.Macros.Base : macros;
import Fins.Model;
import Tools.Logging;

mapping plugins = ([]);
mapping engines = ([]);
mapping render_methods = ([]);
mapping render_macros = ([]);
mapping event_handlers = ([]);
mapping internal_path_handlers = ([]);

static void create(Fins.Configuration _config)
{
  config = _config;

  app::create(_config);

  Locale.register_project(config->app_name, combine_path(config->app_dir, "locale/%L/finscribe.xml"));

  load_plugins();
}

void kick_model()
{
  load_model();
}

void load_cache()
{
  cache = FinScribe.Cache;
}

void load_plugins()
{
	string plugindir = Stdio.append_path(config->app_dir, "plugins");
	array p = get_dir(plugindir);
//	Log.info("current directory is " + getcwd());
	foreach(p||({});;string f)
	{
		if(f == "CVS") continue;
		
		Log.info("Considering plugin " + f);
		Stdio.Stat stat = file_stat(Stdio.append_path(plugindir, f));
//        Log.info("STAT: %O %O", Stdio.append_path(plugindir, f), stat);
		if(stat && stat->isdir)
		{
//			Log.info("  is a directory based plugin.");

            object installer;
            object module;
			string pd = combine_path(plugindir, f);
			
			foreach(glob("*.pike", get_dir(pd));; string file)
			{
				program p = (program)combine_path(pd, file);
//				Log.info("File: %O", p);
				if(Program.implements(p, FinScribe.PluginInstaller) && !installer)
				  installer = p(this);
				if(Program.implements(p, FinScribe.Plugin) && !module)
				  module = p(this);	

               
			}
			
			if(!module || module->name =="")
			{
				Log.error("Module %s has no name, not loading.", f);
				continue;
			}
			
			if(installer && functionp(installer->install) && module->installed())
			    installer->install(Filesystem.System(pd));
			plugins[module->name] = module;
		}
	}
	
	start_plugins();
}

void start_plugins()
{
	Log.debug("Starting plugins.");

	
	foreach(plugins;string name; object plugin)
	{
           Log.debug("Processing " + name);

           // we don't start up plugins that explicitly tell us not to.
           if(plugin->enabled && !plugin->enabled())
             continue;
           Log.debug("Starting " + name);

		if(plugin->start && functionp(plugin->start))
		  plugin->start();

                if(plugin->query_macro_callers && 
                        functionp(plugin->query_macro_callers))
                {
                  Log.debug(name + " has a macro caller.");
                  mapping a = plugin->query_macro_callers();
                  if(a)
                    foreach(a; string m; Public.Web.Wiki.Macros.Macro code)
                    {
   	               Log.debug("adding macro " + m + ".");
                       render_macros[m] = code;
                    }
                }

                if(plugin->query_type_callers && 
                        functionp(plugin->query_type_callers))
                {
                  mapping a = plugin->query_type_callers();

                  if(a)
                    foreach(a; string m; Public.Web.Wiki.RenderEngine code)
                    {
   	               Log.debug("adding handler for " + m + ".");
                       engines[m] = code;
                    }
                }

                if(plugin->query_event_callers && 
                        functionp(plugin->query_event_callers))
                {
                  mapping a = plugin->query_event_callers();

                  if(a)
                    foreach(a; string m; function event)
                    {
   	               Log.debug("adding handler for " + m + ".");
                       if(!event_handlers[m])
                          event_handlers[m] = ({});
                       event_handlers[m] += ({ event });
                    }
                }

                if(plugin->query_ipath_callers && 
                        functionp(plugin->query_ipath_callers))
                {
                  mapping a = plugin->query_ipath_callers();

                  if(a)
                    foreach(a; string m; mixed f)
                    {
   	               Log.debug("adding internal path handler for " + m + ".");
                       internal_path_handlers[m] = f;
                    }
                }

	}

  foreach(engines;;object e)
  {
    foreach(render_macros; string m; object c)
     e->add_macro(m, c);
  }
}

int trigger_event(string event, mixed ... args)
{
  int retval;
  Log.debug("Calling event " + event);
  if(event_handlers[event])
  {
    foreach(event_handlers[event];; function h)
    {
      int res = h(event, @args);

      retval|=res; 
 
      if(res & FinScribe.abort)
         break;
    }
  }
  return retval;
}

int install()
{
  object i = ((program)"install")(this);
  return i->run();
}

public string render_wiki(string contents)
{
  function f = render_methods["text/wiki"];

  if(f)
    return f(contents, ([]), ([]));
  else return contents;

}

public string render(string contents, FinScribe.Model.Object obj, Fins.Request|void id)
{
  string t;
  if(obj)
    t = obj["datatype"]["mimetype"];
  function f;

 if(!t && (id && id->variables->datatype))
  {
    t = id->variables->datatype;
  }
  else if(!t)
  {
    t = "text/wiki";
  }

  f = render_methods[t];

  if(!f && obj)
  {
    object n = get_renderer_for_type(obj["datatype"]["mimetype"]);
    if(n && n->render) render_methods[t] = f = n->render;
  }

  if(f)
    return f(contents, (["request": id, "obj": obj]), ((id&&id->variables->weblog)?1:0));
  else return contents;
}

public string get_widget_for_type(string type, string contents)
{
  object t = get_renderer_for_type(type);

  if(!t || !t->get_widget)
  {
    return "<textarea id=\"contents\" name=\"contents\" rows=\"10\" cols=\"600\">" + 
                  contents + "</textarea>";
  }

  else return t->get_widget(contents);
}

public Public.Web.Wiki.RenderEngine get_renderer_for_type(string type)
{
  if(engines[type])
    return engines[type];
}

public void set_default_data(Fins.Request id, object t)
{
  if(id->misc->session_variables->userid)
  {
     object user = model->find_by_id("user", id->misc->session_variables->userid);
     t->add("user_object", user);
     t->add("UserName", user["UserName"]);
     t->add("is_admin", user["is_admin"]);
     t->add("user", user["Name"]);
  }
}

public int is_admin_user(Fins.Request id, Fins.Response response)
{
  if(!id->misc->session_variables->userid)
  {
    response->flash("msg", "You must be logged in as an administrator to continue.");
    response->redirect("/exec/login");
    return 0;
  }

  object user = model->find_by_id("user", id->misc->session_variables->userid);
  
  if(!user)
  {
    response->flash("msg", "Unable to find a user for your userid.");
    response->redirect("/exec/login");
    return 0;
  }
  
  if(user["is_admin"])
    return 1;
  else
  {
    response->flash("msg", "You must be an administrator to access that resource.");
    response->redirect("/exec/login");
    return 0;
  }
}

mixed get_sys_pref(string pref)
{
  FinScribe.Model.Preference p;
  array x = model->find("preference", (["Name": pref]));

  if(x && sizeof(x))
    return x[0];

  else return 0;
  
}

object new_string_pref(string pref, string value)
{
  object p = get_sys_pref(pref);
  if(p) return p;
  else 
  { 

     p = FinScribe.Repo.new("preference");
     p["Name"] = pref;
     p["Type"] = FinScribe.STRING;
     p["Value"] = value;
     p->save();
     return p;
  }

}

object new_pref(string pref, string value, int type)
{
  object p = get_sys_pref(pref);
  if(p) return p;
  else 
  { 

     p = FinScribe.Repo.new("preference");
     p["Name"] = pref;
     p["Type"] = type;
     p["Value"] = value;
     p->save();
     return p;
  }

}

