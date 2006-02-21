//<locale-token project="FinScribe">LOCALE</locale-token>

#define LOCALE(X,Y) Locale.translate(app->config->app_name, id->get_lang(), X, Y)

Fins.FinsController plugin;

static void create(object app)
{
  ::create(app);

  plugin = ((program)"admin/plugin_controller")(app);
}

import Fins;
inherit Fins.FinsController;

public void index(Request id, Response response, mixed ... args)
{
	if(!app->is_admin_user(id, response))
          return;

    object t = view->get_view("admin/adminindex");

    app->set_default_data(id, t);

	response->set_view(t);
}

public void shutdown(Request id, Response response, mixed ... args)
{
	if(!app->is_admin_user(id, response))
          return;
	object t;
		
	if(!id->variables->really_shutdown)
	  t = view->get_view("admin/confirmshutdown");
	else
	{	 
		t = view->get_view("admin/shutdown");
			// this is bad, we should have a better way of doing this...
			call_out(exit, 5, 0);
		}
	        app->set_default_data(id, t);
	
		response->set_view(t);
	
}

public void getusers_json(Request id, Response response, mixed ... args)
{
  string json;
  array j = ({});
  array x;

  if(!app->is_admin_user(id, response))
    return;

  if(!sizeof(args))
   x = model->find("user", ([]));
  else
  {
    object g = model->find_by_id("group", (int)args[0]);
    
    x = g["users"];
  }

  foreach((array)x;;mixed g)
  {
    j += ({([ "name": g["Name"] + " [" + g["UserName"] + "]", "value": g["id"] ])});
  } 

  json = Tools.JSON.serialize((["data": j]));

  response->set_data(json);
  response->set_type("text/javascript");
}

public void getgroups_json(Request id, Response response, mixed ... args)
{

  if(!app->is_admin_user(id, response))
    return;

  string json;
  array j = ({});
  array x = model->find("group", ([]));

  foreach(x;;mixed g)
  {
    j += ({([ "name": g["Name"], "value": g["id"] ])});
  } 

  json = Tools.JSON.serialize((["data": j]));

  response->set_data(json);
  response->set_type("text/javascript");
}

public void listusers(Request id, Response response, mixed ... args)
{
	if(!app->is_admin_user(id, response))
          return;

     object t = view->get_view("admin/listusers");

     app->set_default_data(id, t);

	mixed ul;

	if(!id->variables->limit)
		ul = model->find("user",([]));
	
	t->add("users", ul);
	
	response->set_view(t);
}

public void listgroups(Request id, Response response, mixed ... args)
{
	if(!app->is_admin_user(id, response))
          return;

    object t = view->get_view("admin/listgroups");

    app->set_default_data(id, t);

	mixed ul;

	if(!id->variables->limit)
		ul = model->find("group",([]));
	
	t->add("groups", ul);
	
	response->set_view(t);
}

public void editgroup(Request id, Response response, mixed ... args)
{
	if(!app->is_admin_user(id, response))
          return;
   
    object t = view->get_view("admin/editgroup");
	
    app->set_default_data(id, t);

        
        object g = model->find_by_id("group", (int)id->variables->groupid);
	   t->add("group", g);

        if(id->variables->action)
        {
          if(id->variables->action == LOCALE(0, "Cancel"))
          {
            response->redirect("/admin");
            return;
          }

          else if(id->variables->action == LOCALE(0, "Save"))
          {

werror("DATA: %O\n", id->variables);
            if(id->variables->Name != g["Name"])
               g["Name"] = id->variables->Name;

            if(id->variables->added != "")
            {
              array a = id->variables->added / ",";
              foreach(a;;string toadd)
              {
                 object x = model->find_by_id("user", (int)toadd);
                 g["users"] += x;
              }
            }

            if(id->variables->removed != "")
            {
              array a = id->variables->removed / ",";
              foreach(a;;string toremove)
              {
                 object x = model->find_by_id("user", (int)toremove);
                 g["users"] -= x;
              }
            }

            response->flash("msg", "Group was updated successfully.");
            response->redirect("/admin/listgroups");
            return;
          }
        }

  	response->set_view(t);
}

public void edituser(Request id, Response response, mixed ... args)
{
	if(!app->is_admin_user(id, response))
          return;

      object t = view->get_view("admin/edituser");
	
    app->set_default_data(id, t);
  	response->set_view(t);

    object u = model->find_by_id("user", (int)id->variables->userid);
	t->add("user", u);

        if(id->variables->action)
        {
          if(id->variables->action == LOCALE(0, "Cancel"))
          {
            response->redirect("/admin");
            return;
          }

          else if(id->variables->action == LOCALE(0, "Save"))
          {
            if(id->variables->Name != u["Name"])
               u["Name"] = id->variables->Name;

            if(id->variables->Name != u["Email"])
               u["Email"] = id->variables->Email;


            if(id->variables->Password && sizeof(id->variables->Password))
            {
               if(id->variables->Password != id->variables->ConfirmPassword)
               {
                 response->flash("msg", "You entered two differing passwords.");
                 return;
               }

               u["Password"] = id->variables->Password;
            }

            response->flash("msg", "User was updated successfully.");
            response->redirect("/admin/listusers");
            return;
          }
        }

}

public void deleteuser(Request id, Response response, mixed ... args)
{
	if(!app->is_admin_user(id, response))
          return;

  object u;

  if(!id->variables->userid)
  {
    response->flash("msg", "No user provided.");
  }
  if(!(u = model->find_by_id("user", (int)id->variables->userid)))
  {
    response->flash("msg", "User id " + id->variables->userid + " does not exist.");
  }
  else
  {
    string n = u["Name"];
    u->delete();
    response->flash("msg", "User " + n + " deleted.");
  }
  response->redirect("listusers");

}

public void toggle_useractive(Request id, Response response, mixed ... args)
{
	if(!app->is_admin_user(id, response))
          return;
  object u;

  if(!id->variables->userid)
  {
    response->flash("msg", "No user provided.");
  }
  if(!(u = model->find_by_id("user", (int)id->variables->userid)))
  {
    response->flash("msg", "User id " + id->variables->userid + " does not exist.");
  }
  else
  {
    u["is_active"] = !u["is_active"];
    
    string pre = "";
    if(!u["is_active"]) pre = "de";
    response->flash("msg", "User " + u["Name"] + " " + pre + "activated.");
  }
  response->redirect("listusers");
}


public void toggle_useradmin(Request id, Response response, mixed ... args)
{
	if(!app->is_admin_user(id, response))
          return;
  object u;

  if(!id->variables->userid)
  {
    response->flash("msg", "No user provided.");
  }
  if(!(u = model->find_by_id("user", (int)id->variables->userid)))
  {
    response->flash("msg", "User id " + id->variables->userid + " does not exist.");
  }
  else
  {
    u["is_admin"] = !u["is_admin"];
    
    string pre = "granted";
    if(!u["is_admin"]) pre = "revoked";
    response->flash("msg", "User administrative rights " + pre + " for " + 
       u["Name"] + ".");
  }
  response->redirect("listusers");
}

