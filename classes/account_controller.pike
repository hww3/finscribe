//<locale-token project="FinScribe">LOCALE</locale-token>

#define LOCALE(X,Y) Locale.translate(app->config->app_name, id->get_lang(), X, Y)

import Tools.Logging;

Fins.FinsController prefs;

void start()
{
  before_filter(app->user_filter);
//  plugin = load_controller("admin/plugin_controller");
}

import Fins;
inherit Fins.FinsController;

public void index(Request id, Response response, mixed ... args)
{
   object t;

    if(id->variables->_ajax || id->variables->ajax) 
	  t = view->get_idview("account/_index");
	else
	  t = view->get_idview("account/index");

    t->add("in_admin", 1);

    app->set_default_data(id, t);

  response->set_view(t);
}


public void listwip(Request id, Response response, mixed ... args)
{
    object t = view->get_idview("admin/listwip");

    app->set_default_data(id, t);

    mixed ul;
    object u = Fins.DataSource._default.find.users_by_id((int)id->variables->userid);

    ul = Fins.DataSource._default.find.objects((["is_attachment": 3, "author": u]));
    t->add("wipblog", ul);

    ul = Fins.DataSource._default.find.objects((["is_attachment": 4, "author": u]));
    t->add("wipobj", ul);

    t->add("in_admin", 1);
	
    response->set_view(t);
}

public void edit(Request id, Response response, mixed ... args)
{
      object t = view->get_idview("account/edit");
	
    app->set_default_data(id, t);
  	response->set_view(t);
    t->add("in_admin", 1);

    object u = Fins.DataSource._default.find.users_by_id((int)id->variables->userid);
	t->add("user", u);

        if(id->variables->action)
        {
          if(id->variables->action == "Cancel")
          {
            response->redirect(index);
            return;
          }

          else if(id->variables->action == "Save")
          {
            if(id->variables->name != u["name"])
               u["name"] = id->variables->name;

            if(id->variables->email != u["email"])
               u["email"] = id->variables->email;


            if(id->variables->password && sizeof(id->variables->password))
            {
               if(id->variables->password != id->variables->confirmpassword)
               {
                 response->flash("msg", LOCALE(315,"You entered two differing passwords."));
                 return;
               }

               u["password"] = id->variables->password;
            }

            response->flash("msg", LOCALE(0,"Settings updated successfully."));
            response->redirect(index);
            return;
          }
        }

}

