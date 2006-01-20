import Fins;
inherit Fins.Application : app;
inherit Fins.Helpers.Macros.Base : macros;
import Fins.Model;
import Tools.Logging;

mapping plugins = ([]);

Public.Web.Wiki.RenderEngine engine;

static void create(Fins.Configuration _config)
{
  config = _config;

  load_wiki();

  app::create(_config);

  Locale.register_project(config->app_name, combine_path(config->app_dir, "locale/%L/finscribe.xml"));
}

void load_cache()
{
  cache = FinScribe.Cache;
}

void load_wiki()
{
   engine = ((program)"wikiengine")(this);
}

void load_plugins()
{
	array p = get_dir("plugins");
	
	foreach(p;;string f)
	{
		Log.info("Considering plugin " + f);
		Stdio.Stat stat = file_stat(combine_path("plugins", f));
		if(stat->isdir)
		{
			Log.info("  is a directory based plugin.");

            object installer;
            object module;

			foreach(glob("*.pike", get_dir(combine_path("plugins", "f")));; string file)
			{
				program p = (program)file;
				if(Program.implements(p, FinScribe.PluginInstaller))
				  installer = p(this);
				else if(Program.implements(p, FinScribe.PluginInstaller))
				  module = p(this);
				
			}
			
			if(module && module->name =="")
			{
				Log.error("Module %s has no name, not loading.", file);
				continue;
			}
			
			if(installer && functionp(installer->install))
			    installer->install();
			plugins[module->name] = module;

		}
	}
}

int install()
{
  object i = ((program)"install")(this);
  return i->run();
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
