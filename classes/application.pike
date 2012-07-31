//<locale-token project="FinScribe">LOCALE</locale-token>

#define LOCALE(X,Y) Locale.translate(config->app_name, id->get_lang(), X, Y)

import Fins;
import Fins.Model;
import Tools.Logging;
inherit "default_preferences" : defpref;
inherit Fins.Application : app;

mapping included_by = ([]);
mapping plugins = ([]);
mapping engines = ([]);
mapping render_methods = ([]);
mapping render_macros = ([]);
mapping event_handlers = ([]);
mapping internal_path_handlers = ([]);
mapping preferences = ([]);

static void create(object config)
{
  ::create(config);
}

void start()
{
  Locale.register_project(config->app_name, combine_path(config->app_dir,     
    "translations/%L/FinScribe.xml"));


  if(config["application"] && (int)config["application"]["installed"])
  {
    load_preferences();
    load_plugins();
  }
}

void kick_model()
{
  load_model();
  load_preferences();
  load_plugins();
}

void load_cache()
{
//  cache = Fins.Cache.Cache();
  cache = FinScribe.Cache;
}

void load_plugins()
{
	string plugindir = Stdio.append_path(config->app_dir, "plugins");
	array p = get_dir(plugindir);
//	logger->info("current directory is " + getcwd());
	foreach(p||({});;string f)
	{
		if(f == "CVS") continue;
		
		logger->info("Considering plugin " + f);
		Stdio.Stat stat = file_stat(Stdio.append_path(plugindir, f));
//        logger->info("STAT: %O %O", Stdio.append_path(plugindir, f), stat);
		if(stat && stat->isdir)
		{
//			logger->info("  is a directory based plugin.");

            object installer;
            object module;
			string pd = combine_path(plugindir, f);
			
			foreach(glob("*.pike", get_dir(pd));; string file)
			{
				program p = (program)combine_path(pd, file);
//				logger->info("File: %O", p);
				if(Program.implements(p, FinScribe.PluginInstaller) && !installer)
				  installer = p(this);
				else if(Program.implements(p, FinScribe.Plugin) && !module)
				  module = p(this);	
                                else continue;
                                module->module_dir = pd;
               
			}
			
			if(!module || module->name =="")
			{
				logger->error("Module %s has no name, not loading.", f);
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
	logger->debug("Starting plugins.");
        // sort plugins by startup_priority;
	array x = values(plugins)["name"];
        array y = values(plugins)["startup_priority"];
        sort(y, x);	

	foreach(x;; string name)
	{
           object plugin = plugins[name];
           logger->debug("Processing " + name);

           // we don't start up plugins that explicitly tell us not to.
           if(plugin->enabled && !plugin->enabled())
             continue;
           logger->debug("Starting " + name);

                if(plugin->query_preferences && functionp(plugin->query_preferences))
                {
                  foreach(plugin->query_preferences(); string p; mapping pv)
                  {
                    new_pref("plugin." + plugin->name + "." + p, pv);
                  }
                }

		if(plugin->start && functionp(plugin->start))
		  plugin->start();

                if(plugin->query_macro_callers && 
                        functionp(plugin->query_macro_callers))
                {
                  logger->debug(name + " has a macro caller.");
                  mapping a = plugin->query_macro_callers();
                  if(a)
                    foreach(a; string m; Public.Web.Wiki.Macros.Macro code)
                    {
   	               logger->debug("adding macro " + m + ".");
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
   	               logger->debug("adding handler for " + m + ".");
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
			add_event_handler(m, event);
                    }
                }

                if(plugin->query_ipath_callers && 
                        functionp(plugin->query_ipath_callers))
                {
                  mapping a = plugin->query_ipath_callers();

                  if(a)
                    foreach(a; string m; mixed f)
                    {
   	               logger->debug("adding internal path handler for " + m + ".");
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


int add_event_handler(string event, function handler)
{
  logger->debug("adding handler for " + event + ".");
  if(!event_handlers[event])
    event_handlers[event] = ({});
  event_handlers[event] += ({ handler });
}

int trigger_event(string event, mixed ... args)
{
  int retval;
  logger->debug("Calling event " + event);
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

string get_theme(object id)
{
  object p;
  string t;
  p = new_string_pref("site.theme", "default");
  t = p->get_value();

  if(!stringp(t))
  {
    logger->warn("Got unexpected value during theme retrieval: %O in %O", t, 
         p->get_atomic());
  }
  return t;
}

public string render_wiki(string contents)
{
  function f = render_methods["text/wiki"];

  if(f)
    return f(contents, ([]), ([]));
  else return contents;

}

public string render(string contents, FinScribe.Objects.Object obj, Fins.Request|void id, int|void force)
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

//werror("rendering %O as %O\n", obj?obj["path"]:"unknown", t);
  if(id &&  id["request_headers"]
        && id["request_headers"]["pragma"] == "no-cache")
  {
    logger->info("Pragma: No-cache included as part of request. Forcing render.");
    force = 1;
  }

  f = render_methods[t];

  if(!f && obj)
  {
    object n = get_renderer_for_type(obj["datatype"]["mimetype"]);
    if(n && n->render) render_methods[t] = f = n->render;
  }

  if(f)
  {
     if(id && id->misc && id->misc->current_page_stack) id->misc->current_page_stack->push(obj);
     mixed rv = f(contents, (["request": id, "obj": obj]), ((force||(id&&id->variables->weblog))?1:0));
     if(id && id->misc && id->misc->current_page_stack) id->misc->current_page_stack->pop();
     return rv;
  }
  else return contents;
}

public string get_widget_for_type(object view, string type, string contents)
{
//  werror("get_widget_for_type(%O, %O, %O)\n", view, type, contents);
  object t = get_renderer_for_type(type);

  if(!t || !t->get_widget)
  {
    werror("using default widget.\n");
    return "This editor uses Wiki markup. Read about <a target=\"new\" href=\"http://bill.welliver.org/space/pike/FinScribe/Documentation/Wiki+Markup\">wiki syntax</a>."
	"<textarea style=\"width: 100%;\" id=\"contents\" name=\"contents\" rows=\"10\">" + 
                  contents + "</textarea>";
  }

  else return t->get_widget(view, contents);
}

public Public.Web.Wiki.RenderEngine get_renderer_for_type(string type)
{
  if(engines[type])
    return engines[type];
}

public void set_default_data(Fins.Request id, object|mapping t)
{
  if(t->data && t->data->set_request)
    t->data->set_request(id);
  else if(t->set_request)
    t->set_request(id);

  object user = get_current_user(id);
  if(!user) return 0;

     if(mappingp(t))
     {
       t["user_object"] = user;
       t["is_admin"] = user["is_admin"];
     }
     else
     {
       t->add("user_object", user);
       t->add("is_admin", user["is_admin"]);
     }

}

int admin_user_filter(Fins.Request id, Fins.Response response, mixed ... args)
{
//werror("admin_user_filter: %O\n", id);
  return is_admin_user(id, response);
}

int user_filter(Fins.Request id, Fins.Response response, mixed ... args)
{
  return is_user(id, response);
}

object get_current_user(object id)
{
  object user;

  if(id->misc->session_variables && id->misc->session_variables->userid)
  {
     user = Fins.DataSource->_default->find_by_id("User", id->misc->session_variables->userid);
  }

  return user;
}

public int is_admin_user(Fins.Request id, Fins.Response response)
{
werror("misc: %O\n", id->misc);
  if(!id->misc->session_variables->userid)
  {
    response->flash(LOCALE(331,"You must be logged in as an administrator to continue."));
    response->redirect("/exec/login");
    return 0;
  }

  object user = Fins.DataSource->_default->find_by_id("User", id->misc->session_variables->userid);
  
  if(!user)
  {
    response->flash(LOCALE(332,"Unable to find a user for your userid."));
    response->redirect("/exec/login");
    return 0;
  }
  
  if(user["is_admin"])
    return 1;
  else
  {
    response->flash(LOCALE(333,"You must be an administrator to access that resource."));
    response->redirect("/exec/login");
    return 0;
  }
}

public int is_user(Fins.Request id, Fins.Response response)
{
  if(!id->misc->session_variables->userid)
  {
    response->flash(LOCALE(0,"You must be logged in to continue."));
    response->redirect("/exec/login");
    return 0;
  }

  object user = Fins.DataSource->_default->find_by_id("User", id->misc->session_variables->userid);
  
  if(!user)
  {
    response->flash(LOCALE(332,"Unable to find a user for your userid."));
    response->redirect("/exec/login");
    return 0;
  }
  
  if(user["is_active"])
    return 1;
  else
  {
    response->flash(LOCALE(333,"You must be an active user to access that resource."));
    response->redirect("/exec/login");
    return 0;
  }
}

mixed handle_request(Request request)
{
  request->misc->current_page_stack = ADT.Stack();
  
  return ::handle_request(request);
}

mapping get_preference_definition(object pref)
{
  write("basename: %O\n", pref["basename"]);
  mapping pd = preferences[pref["basename"]] + ([]);

  if(functionp(pd["options"]))
    pd["options"] = pd["options"]();

  return pd;
}

object get_sys_pref(string pref)
{
  FinScribe.Objects.Preference p;
  mixed err = catch(p = Fins.DataSource["_default"]->find->preferences_by_alt(pref));
  if((err = Error.mkerror(err)) && !err->_is_recordnotfound_error) throw(err);
  return p;
}

//! @param defs
//!  optional mapping containing keys to set on new object if it doesn't exist already.
object new_string_pref(string pref, string value, mapping|void defs)
{
  object p;
  p = get_sys_pref(pref);
  if(p) return p;
  else 
  { 
     logger->info("Creating new preference object '" + pref  + "'.");
     p = FinScribe.Objects.Preference();
     p["name"] = pref;
     p["type"] = FinScribe.STRING;
     p["value"] = value;
     p["description"] = "";
     if(defs)
     {
       foreach(defs; string k; string v)
         p[k] = v;
     }
     p->save();
     return p;
  }
}

//! @param defs
//!  optional mapping containing keys to set on new object if it doesn't exist already.
object new_boolean_pref(string pref, string value, mapping|void defs)
{
  object p;
  p = get_sys_pref(pref);
  if(p) return p;
  else 
  { 
     logger->info("Creating new preference object '" + pref  + "'.");
     p = FinScribe.Objects.Preference();
     p["name"] = pref;
     p["type"] = FinScribe.BOOLEAN;
     p["value"] = (int)value;
     p["description"] = "";
     if(defs)
     {
       foreach(defs; string k; string v)
         p[k] = v;
     }
     p->save();
     return p;
  }
}

//! register a new preference with the application.
//! a class or plugin should register all preferences it is interested in at startup. 
//! if a given preference is not present in the persistent store (model), it will be added
//! with the default value (or the first of the option set) configured as its value.
//! additionally, the metadata about the preference will be stored in the application's 
//! temporal preference registry for use by the administration interface. 
object new_pref(string pref, mapping data, mapping|void defs)
{
  object p;

  if(!preferences[pref]) preferences[pref] = ((["name":pref, "friendly_name": pref]) | data);

  p = get_sys_pref(pref);
  if(p) return p;
  else 
  { 
     p = FinScribe.Objects.Preference();
     p["name"] = pref;
     p["type"] = data->type;
     p["description"] = data->description||"";
     p["value"] = data->value || ((arrayp(data->options) && sizeof(data->options))?data->options[0]:0);
     if(defs)
     {
       foreach(defs; string k; string v)
         p[k] = v;
     }
     p->save();
     return p;
  }
}
