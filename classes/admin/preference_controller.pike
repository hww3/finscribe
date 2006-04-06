//<locale-token project="FinScribe">LOCALE</locale-token>

#define LOCALE(X,Y) Locale.translate(app->config->app_name, id->get_lang(), X, Y)


import Fins;
inherit Fins.FinsController;

public void index(Request id, Response response, mixed ... args)
{
  response->redirect("list");
}

public void list(Request id, Response response, mixed ... args)
{
	if(!app->is_admin_user(id, response))
          return;

     object t = view->get_view("admin/prefs/list");

     app->set_default_data(id, t);

     mixed ul = ({});
    mapping c = ([]);
    if(id->variables->startswith) c->Name = Fins.Model.LikeCriteria(id->variables->startswith + "%");
    ul = model->find("preference", c,  Fins.Model.Criteria("ORDER BY Name DESC"));

     t->add("preferences", ul);
	
     response->set_view(t);
}

public void toggle_enabled(Request id, Response response, mixed ... args)
{
  if(!app->is_admin_user(id, response))
     return;
  object u;

  if(!id->variables->plugin)
  {
    response->flash("msg", "No plugin.");
  }

  else if(!app->plugins[id->variables->plugin])
  {
	response->flash("msg", "Plugin enumeration failure.");
  }

  else
  {
	object p = app->get_sys_pref("plugin." + app->plugins[id->variables->plugin]->name + ".enabled");
    p["Value"] = !p->get_value();
    response->flash("msg", "Plugin " + id->variables->plugin + " " + (p->get_value()?"en":"dis") + "abled.");
  }

  response->redirect("list");
}
