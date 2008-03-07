//<locale-token project="FinScribe">LOCALE</locale-token>

#define LOCALE(X,Y) Locale.translate(app->config->app_name, id->get_lang(), X, Y)

import Fins;
inherit Fins.FinsController;

static void start()
{
  before_filter(app->admin_user_filter);
}

public void index(Request id, Response response, mixed ... args)
{
  response->redirect("list");
}

public void list(Request id, Response response, mixed ... args)
{
     object t = view->get_view("admin/plugin/list");

     app->set_default_data(id, t);

     mixed ul = ({});

     foreach(sort(indices(app->plugins));; mixed p)
     {
       ul += ({ (["name": app->plugins[p]->name, "description": app->plugins[p]->description,
                  "enabled": app->plugins[p]->enabled()]) });
     }

     t->add("plugins", ul);
	
     response->set_view(t);
}

public void toggle_enabled(Request id, Response response, mixed ... args)
{
  object u;

  if(!id->variables->plugin)
  {
    response->flash("msg", LOCALE(0,"No plugin."));
  }

  else if(!app->plugins[id->variables->plugin])
  {
	response->flash("msg", LOCALE(0,"Plugin enumeration failure."));
  }

  else
  {
	object p = app->get_sys_pref("plugin." + app->plugins[id->variables->plugin]->name + ".enabled");
    p["Value"] = !p->get_value();
    if(p->get_value())
      response->flash("msg", sprintf(LOCALE(0,"Plugin %[0]s enabled."), id->variables->plugin));
    else
      response->flash("msg", sprintf(LOCALE(0,"Plugin %[0]s disabled."), id->variables->plugin));
  }

  response->redirect("list");
}
