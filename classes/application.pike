import Fins;
inherit Fins.Application : app;
inherit Fins.Helpers.Macros.Base : macros;
import Fins.Model;

Public.Web.Wiki.RenderEngine engine;

static void create(Fins.Configuration _config)
{
  config = _config;

  load_wiki();

  app::create(_config);

  Locale.register_project(config->app_name, combine_path(config->app_dir, "locale/%L/finscribe.xml"));

  Template.add_simple_macro("breadcrumbs", macro_breadcrumbs);
  Template.add_simple_macro("snip", macro_snip);
  
}

void load_cache()
{
  cache = FinScribe.Cache;
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

string simple_macro_folding_div(Fins.Template.TemplateData data, mapping|void arguments)
{
  String.Buffer b = String.Buffer();

  b+="<a id='";
  b+=arguments["name"];
  b+=" onclick=\"toggleVisibility('";
  b+=arguments["name"];
  b+="')\"><img id=\"icon-";
  b+=arguments["name"];
  b+="\" src=\"/static/images/Icon-Unfold.png\" border=\"0\">";

  b+=arguments["title"];
  b+="<br/><div id=\"";
  b+=arguments["name"];
  b+="\" style=\"display:none;margin-left:20px\">";

  return b->get();
}



string macro_breadcrumbs(Template.TemplateData data, mapping|void args)
{
  if(!mappingp(args)) return "";
  return get_page_breadcrumbs(get_var_value(args->var, data->get_data())||args->val||"");
}

string macro_snip(Template.TemplateData data, mapping|void args)
{
   if(!mappingp(args)) return "";
   if(!args->snip) return "";
   object obj = model->get_fbobject((args->snip)/"/");

   if(!obj) return "";

   string contents = obj->get_object_contents();

   return engine->render(contents);
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
     dta->add("user_object", user);
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
