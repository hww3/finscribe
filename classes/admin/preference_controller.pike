//<locale-token project="FinScribe">LOCALE</locale-token>

#define LOCALE(X,Y) Locale.translate(app->config->app_name, id->get_lang(), X, Y)

import Fins;
import Tools;
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

public void set(Request id, Response response, mixed ... args)
{
  if(!app->is_admin_user(id, response)) {
    response->flash("msg", "Only admin user can change preferences!");
    response->redirect("list");
  }

  if (id->variables->key && id->variables->value) {
    object pref = app->get_sys_pref(id->variables->key);
    if (pref) {
      if(pref["Type"] == FinScribe.BOOLEAN)
      {
        if(lower_case(id->variables->value) == "false" || !(int)id->variables->value)
          pref["Value"] = 0;
        else
          pref["Value"] = 1;

      }
      pref["Value"] = id->variables->value;
      response->set_data(JSON.serialize(([ set : 1 ])));
      response->set_type("text/javascript");
    }
  }
  else {
    response->set_data(JSON.serialize(([ set : 0 ])));
    response->set_type("text/javascript");
  }
}
