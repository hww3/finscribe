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

     object t = view->get_view("admin/plugin/list");

     app->set_default_data(id, t);

     mixed ul = ({});

     foreach(app->plugins;; mixed p)
     {
       ul += ({ (["name": p->name, "description": p->description,
                  "enabled": p->enabled() ]) });
     }

     t->add("plugins", ul);
	
     response->set_view(t);
}
