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

    t->add("in_admin", 1);

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
    t->add("in_admin", 1);
	
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
  array x = ({});

  if(!sizeof(args))
    x = model->find("group", ([]));
  else
  {
    object u = model->find_by_id("user", (int)args[0]);
    if(u)
       x = model->find("group", (["users": u]));
  }

  foreach(x;;mixed g)
  {
    j += ({([ "name": g["Name"], "value": g["id"] ])});
  } 

  json = Tools.JSON.serialize((["data": j]));

  response->set_data(json);
  response->set_type("text/javascript");
}

public void listacls(Request id, Response response, mixed ... args)
{
	if(!app->is_admin_user(id, response))
          return;

     object t = view->get_view("admin/listacls");

     app->set_default_data(id, t);

	mixed ul;

	if(!id->variables->limit)
		ul = model->find("acl",([]));
	
	t->add("acls", ul);
    t->add("in_admin", 1);
	
	response->set_view(t);
}

public void editacl(Request id, Response response, mixed ... args)
{
    if(!app->is_admin_user(id, response))
      return;
   
    object t = view->get_view("admin/editacl");
	
    app->set_default_data(id, t);
    t->add("in_admin", 1);

    object g;

        if(id->variables->aclid)
        {
           g = model->find_by_id("acl", (int)id->variables->aclid);
	   t->add("acl", g);
        }
        else
        {
           t->add("newacl", 1);
        }

        if(id->variables->action)
        {
          if(id->variables->action == LOCALE(0, "Cancel"))
          {
            response->redirect("listacls");
            return;
          }

          else if(id->variables->action == LOCALE(0, "Save"))
          {

            if(id->variables->newacl)
              g = FinScribe.Repo.new("acl");

            if(id->variables->Name != g["Name"])
               g["Name"] = id->variables->Name;

            if(id->variables->newacl)
              g->save();

            response->flash("msg", "ACL was updated successfully.");
            response->redirect("listacls");
            return;
          }
        }

  	response->set_view(t);
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
    t->add("in_admin", 1);
	
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
    t->add("in_admin", 1);
	
	response->set_view(t);
}

public void editgroup(Request id, Response response, mixed ... args)
{
    if(!app->is_admin_user(id, response))
      return;
   
    object t = view->get_view("admin/editgroup");
	
    app->set_default_data(id, t);
    t->add("in_admin", 1);

    object g;

        if(id->variables->groupid)
        {
           g = model->find_by_id("group", (int)id->variables->groupid);
	   t->add("group", g);
        }
        else
        {
           t->add("newgroup", 1);
        }

        if(id->variables->action)
        {
          if(id->variables->action == LOCALE(0, "Cancel"))
          {
            response->redirect("listgroups");
            return;
          }

          else if(id->variables->action == LOCALE(0, "Save"))
          {

            if(id->variables->newgroup)
              g = FinScribe.Repo.new("group");

            if(id->variables->Name != g["Name"])
               g["Name"] = id->variables->Name;

            if(id->variables->newgroup)
              g->save();

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
            response->redirect("listgroups");
            return;
          }
        }

  	response->set_view(t);
}

public void newuser(Request id, Response response, mixed ... args)
{
    if(!app->is_admin_user(id, response))
     return;

    object t = view->get_view("admin/newuser");
	
    app->set_default_data(id, t);
  	response->set_view(t);
    t->add("in_admin", 1);

   string Name, UserName, Email, Password, Password2;
   int is_active, is_admin;

        Name = "";
        UserName = "";
        Email = "";
        Password = "";

        if(id->variables->action)
        {
                Name = id->variables->Name;
                UserName = id->variables->UserName;
                Email = id->variables->Email;
                Password = id->variables->Password;
                Password2 = id->variables->Password2;
                is_active = (int)id->variables->is_active;
                is_admin = (int)id->variables->is_admin;


                if(id->variables->action == "Create")
                {
                        // check the username
                        if(sizeof(Name)< 2)
                        {
                                response->flash("msg", "You must provide a username with at least 2 characters.\n");
                                UserName = "";
                        }
                        else if(sizeof(model->find("user", (["UserName": UserName]))) != 0)
                        {
                                response->flash("msg", "The username you have chosen is already in use by another user.\n");
                                UserName = "";
                        }
                        else if(!sizeof(Name) || !sizeof(Email))
                        {
                                response->flash("msg", "You must provide a Real name and e-mail address.\n");

                                Name = "";
                                Email = "";
                       }
                        else if(sizeof(Password)<4 || (Password != Password2))
                        {
                                response->flash("msg", "Your password must be typed identically in both fields, and must be at least 4 characters long.\n");
                                Password = Password2 = "";
                        }
                        else
                        {
                                // if we got here, everything should be good to go.
                                object u = FinScribe.Repo.new("user");
                                u["UserName"] = UserName;
                                u["Name"] = Name;
                                u["Email"] = Email;
                                u["Password"] = Password;
                                u["is_active"] = is_active;
                                u["is_admin"] = is_admin;
                                u->save();

                               if(id->variables->added != "")
                               {
                                 array a = id->variables->added / ",";
                                 foreach(a;;string toadd)
                                 {
                                    object x = model->find_by_id("group", (int)toadd);
                                    x["users"] += u;
                                  }
                                }

                                response->flash("msg", "User " + UserName + " created successfully.\n");
                                response->redirect("listusers");

// now, let's set up a page for the new user.
                                object p = FinScribe.Repo.find("object", (["path": "themes/default/newuser"]))[0];

                                object up = FinScribe.Repo.new("object");
                                up["path"] = u["UserName"];
                                up["author"] = u;
                                up["datatype"] = p["datatype"];
                                up["is_attachment"] = 0;

                                up->save();
                                up["md"]["locked"] = 1;

                                object uv = FinScribe.Repo.new("object_version");
                                uv["author"] = u;
                                uv["object"] = up;
                                uv["contents"] = p["current_version"]["contents"];
                                uv->save();
                        }
                }
                else if(id->variables->action == "Cancel")
                {
                    response->redirect("listusers");
                    return;
                }
                else
                {
                        response->flash("msg", "Unknown action " + id->variables->action);
                }

        }

          t->add("Name", Name);
          t->add("UserName", UserName);
          t->add("Email", Email);
          t->add("Password", Password);
          t->add("Password2", "");          

}

public void edituser(Request id, Response response, mixed ... args)
{
	if(!app->is_admin_user(id, response))
          return;

      object t = view->get_view("admin/edituser");
	
    app->set_default_data(id, t);
  	response->set_view(t);
    t->add("in_admin", 1);

    object u = model->find_by_id("user", (int)id->variables->userid);
	t->add("user", u);

        if(id->variables->action)
        {
          if(id->variables->action == LOCALE(0, "Cancel"))
          {
            response->redirect("listusers");
            return;
          }

          else if(id->variables->action == LOCALE(0, "Save"))
          {
            if((int)id->variables->is_admin != u["is_admin"])
               u["is_admin"] = (int)id->variables->is_admin;

            if((int)id->variables->is_active != u["is_active"])
               u["is_active"] = (int)id->variables->is_active;

            if(id->variables->Name != u["Name"])
               u["Name"] = id->variables->Name;

            if(id->variables->Email != u["Email"])
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

            if(id->variables->added != "")
            {
              array a = id->variables->added / ",";
              foreach(a;;string toadd)
              {
                 object x = model->find_by_id("group", (int)toadd);
                 x["users"] += u;
              }
            }

            if(id->variables->removed != "")
            {
              array a = id->variables->removed / ",";
              foreach(a;;string toremove)
              {
                 object x = model->find_by_id("group", (int)toremove);
                 x["users"] -= u;
              }
            }



            response->flash("msg", "User was updated successfully.");
            response->redirect("listusers");
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
  else if(id->variables->action == "Really Delete")
  {

    // first, we should reassign the documents.
    object nu = model->find_by_id("user", (int)id->variables->reassign_to);

    foreach(u["objects"];; object x)
      x["author"] = nu;
    foreach(u["object_versions"];; object x)
      x["author"] = nu;

    string n = u["Name"];
    u->delete();
    response->flash("msg", "User " + n + " deleted.");
    response->redirect("listusers");
  }
  else if(id->variables->action == "Cancel")
  {
    response->flash("msg", "User Delete Cancelled");
    response->redirect("listusers");
  }
  else
  {
    object t = view->get_view("admin/confirmdeleteuser");

    app->set_default_data(id, t);

    t->add("in_admin", 1);
    t->add("user", u);
    t->add("all_users", model->find("user", ([])));
    response->set_view(t);
  }
}

public void deletegroup(Request id, Response response, mixed ... args)
{
	if(!app->is_admin_user(id, response))
          return;

  object u;

  if(!id->variables->groupid)
  {
    response->flash("msg", "No group provided.");
  }
  if(!(u = model->find_by_id("group", (int)id->variables->groupid)))
  {
    response->flash("msg", "Group id " + id->variables->groupid + " does not exist.");
  }
  else
  {
    string n = u["Name"];
    u->delete();
    response->flash("msg", "Group " + n + " deleted.");
  }
  response->redirect("listgroups");

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

