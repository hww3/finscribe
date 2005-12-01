import Fins;
inherit Fins.Application;
import Fins.Model;

Public.Web.Wiki.RenderEngine engine;

static void create(Fins.Configuration _config)
{
  config = _config;

	load_wiki();
  ::create(_config);

  Template.add_simple_macro("breadcrumbs", macro_breadcrumbs);
  Template.add_simple_macro("snip", macro_snip);
	Template.add_simple_macro("boolean", macro_boolean);
  
}

void load_wiki()
{
   engine = ((program)"wikiengine")(this);
}

int install()
{
  object i = ((program)"install")(this);
  return i->run();
}

string macro_breadcrumbs(Template.TemplateData data, string|void args)
{
  return get_page_breadcrumbs(data->get_data()[args]||"");
}

string macro_snip(Template.TemplateData data, string|void args)
{
   object obj = model->get_fbobject(args/"/");

   if(!obj) return "";

   string contents = model->get_object_contents(obj);

   return engine->render(contents);
}

string macro_boolean(Template.TemplateData data, string|void args)
{
	array a = args/".";
	mapping d = data->get_data();
	string p = "";
	
	foreach(a;; string elem)
	{
		p = p + "." + elem;
		
		if(!d[elem] && zero_type(d[elem]))
      {
			return "unknown element " + p;
		}
		
		else if (mappingp(d[elem]))
		{
			d = d[elem];
		}
		
		else if (intp(d[elem]))
		{
			return (d[elem] != 0)?"Yes":"No";
		}
		else if(stringp(d[elem]))
		{
			return ((int)d[elem] != 0)?"Yes":"No";
		}
		else
		{
			return "invalid type for boolean " + p;
		}
	}
}

string get_page_breadcrumbs(string page)
{
  array s = ({});
  string newcomponent;
  array p = page/"/";

  // in this application, if we're at the root, 
  // we don't have any place left to go.
  if(sizeof(p) == 1 && p[0]=="start") return "";

  if(p[0] != "start")
    p = ({"start"}) + p;

  foreach(p; int i; string component)
  {
    if(newcomponent && !(i==1))
      newcomponent=newcomponent+"/" + component;
    else
      newcomponent = component;

    if(i == (sizeof(p)-1))
      s += ({ component });
    else
      s += ({ "<a href=\"/space/" + newcomponent + "\">" + component + "</a>" });
  }

  return (s * " &gt; ");
}

public void set_default_data(Fins.Request id, Fins.Template.TemplateData dta)
{
  if(id->misc->session_variables->userid)
  {
     object user = model->find_by_id("user", id->misc->session_variables->userid);
     dta->add("UserName", user["UserName"]);
          dta->add("is_admin", user["is_admin"]);
     dta->add("user", user["Name"]);
  }
}

public int is_admin_user(Fins.Request id, Fins.Response response)
{
  if(!id->misc->session_variables->userid)
  {
    response->flash("msg", "You must be logged in as an administrator to continue.");
    response->redirect(id->referrer || "/space/start");
    return 0;
  }

  object user = model->find_by_id("user", 
id->misc->session_variables->userid);
  
  if(!user)
  {
    response->flash("msg", "Unable to find a user for your userid.");
    response->redirect(id->referrer || "/space/start");
    return 0;
  }
  
  if(user["is_admin"])
    return 1;
  else
  {
    response->flash("msg", "You must be an administrator to access that resource.");
    response->redirect(id->referrer || "/space/start");
    return 0;
  }
}
